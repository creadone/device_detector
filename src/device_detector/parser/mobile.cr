module DeviceDetector::Parser
  struct Mobile
    include Helper

    getter kind = "mobile"
    @@mobiles = Hash(String, SingleModelMobile | MultiModelMobile).from_yaml(Storage.get("mobiles.yml"))
    @@mobile_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/mobiles.yml"))
    @@mobile_entries = nil.as(Array(Tuple(String, SingleModelMobile | MultiModelMobile))?)
    @@huawei_token_prefixes : Hash(String, Array(String)) = begin
      prefixes = Hash(String, Array(String)).new { |hash, key| hash[key] = [] of String }
      rule_index = @@mobiles.keys.index("Huawei") || raise "Huawei mobile rule is missing"
      @@mobile_index.each do |token, indexes|
        prefixes[token[0, 3]] << token if indexes.includes?(rule_index)
      end
      prefixes
    end

    MOBILE_HINTS              = /Mobile|Mobi|Android|iPhone|iPad|iPod|Windows Phone|BlackBerry|BB10|Opera Mini|Opera Mobi|IEMobile|Kindle|Silk|webOS|Tizen|KaiOS|Maemo|MeeGo|Symbian|PlayBook|Tablet|Phone|MIDP|CLDC|Nokia|Samsung|SonyEricsson|HTC|Huawei/i
    APPLE_DEVICE_REGEX        = /\b(iPhone|iPad|iPod)\b/i
    ANDROID_BUILD_MODEL_REGEX = /Android [^;]+; ([^;)]+?)(?: Build|[;)])/i
    APP_DEVICE_MODEL_REGEX    = /Device\/([^\s;)]+)/i
    HUAWEI_VENDOR_HINTS       = /Huawei|Honor|HarmonyOS|OpenHarmony/i
    ANDROID_MODEL_SHORTCUTS   = {
      "SM-G991B"      => {"Samsung", "smartphone", "Galaxy S21 5G"},
      "Pixel 7"       => {"Google", "smartphone", "Pixel 7"},
      "M2101K9G"      => {"Xiaomi", "smartphone", "Mi 11 Lite 5G"},
      "BV6000"        => {"Blackview", "smartphone", "BV6000"},
      "CPH2207"       => {"OPPO", "smartphone", "Reno 5 Pro 5G"},
      "Redmi Note 11" => {"Xiaomi", "smartphone", "Redmi Note 11"},
      "Nokia G20"     => {"Nokia", "smartphone", "G20"},
      "Moto G Power"  => {"Motorola", "smartphone", "Moto G Power"},
    }

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModelMobile
      include YAML::Serializable

      property regex : String

      @[YAML::Field(key: "device")]
      property type : String?

      property model : String
    end

    struct MultiModelMobile
      include YAML::Serializable

      property regex : String

      @[YAML::Field(key: "device")]
      property type : String?

      property models : Array(SingleModelMobile)
    end

    alias MobileRule = SingleModelMobile | MultiModelMobile
    alias ModelCandidate = Tuple(String, Int32)

    @@honor_rule : MobileRule = @@mobiles["Honor"]? || raise "Honor mobile rule is missing"
    @@huawei_rule : MobileRule = @@mobiles["Huawei"]? || raise "Huawei mobile rule is missing"
    @@honor_model_prefixes : Hash(String, Array(ModelCandidate)) = model_prefixes(@@honor_rule)
    @@huawei_model_prefixes : Hash(String, Array(ModelCandidate)) = model_prefixes(@@huawei_rule)

    def mobiles
      return @@mobiles if @@mobiles
      @@mobiles = Hash(String, SingleModelMobile | MultiModelMobile).from_yaml(Storage.get("mobiles.yml"))
    end

    def mobile_index
      return @@mobile_index if @@mobile_index
      @@mobile_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/mobiles.yml"))
    end

    def mobile_entries
      @@mobile_entries ||= mobiles.to_a
    end

    # Compiles every mobile vendor and model rule for parallel parsing.
    def self.prepare : Nil
      patterns = [] of String
      @@mobiles.each_value do |device|
        patterns << device.regex
        if device.is_a?(MultiModelMobile)
          device.models.each { |model| patterns << model.regex }
        end
      end
      Helper.prepare_regexes(patterns)
    end

    # Compiles the Huawei and Honor parent/model rules used by `.huawei?`.
    def self.prepare_huawei : Nil
      patterns = [] of String
      append_rule_patterns(patterns, @@honor_rule)
      append_rule_patterns(patterns, @@huawei_rule)
      Helper.prepare_regexes(patterns)
    end

    # Returns true when the mobile vendor rules identify a Huawei model. Honor
    # is evaluated first to preserve the ordering of the complete parser.
    def self.huawei?(user_agent : String) : Bool
      return false unless huawei_candidate?(user_agent)
      return false if rule_matches?(@@honor_rule, @@honor_model_prefixes, user_agent)

      rule_matches?(@@huawei_rule, @@huawei_model_prefixes, user_agent)
    end

    private def self.huawei_candidate?(user_agent : String) : Bool
      return true if HUAWEI_VENDOR_HINTS =~ user_agent

      if match = user_agent.match(ANDROID_BUILD_MODEL_REGEX) || user_agent.match(APP_DEVICE_MODEL_REGEX)
        return huawei_token?(match[1].strip.downcase)
      end

      user_agent.downcase.scan(Helper::TOKEN_REGEX) do |token_match|
        return true if huawei_token?(token_match[0])
      end

      false
    end

    private def self.huawei_token?(token : String) : Bool
      return false if token.size < 3
      return false unless prefixes = @@huawei_token_prefixes[token[0, 3]]?

      prefixes.any? { |prefix| token.starts_with?(prefix) || prefix.starts_with?(token) }
    end

    private def self.append_rule_patterns(patterns : Array(String), rule : MobileRule) : Nil
      patterns << rule.regex
      if rule.is_a?(MultiModelMobile)
        rule.models.each { |model| patterns << model.regex }
      end
    end

    private def self.model_prefixes(rule : MobileRule) : Hash(String, Array(ModelCandidate))
      prefixes = Hash(String, Array(ModelCandidate)).new { |hash, key| hash[key] = [] of ModelCandidate }
      return prefixes unless rule.is_a?(MultiModelMobile)

      rule.models.each_with_index do |model, model_index|
        model.regex.downcase.scan(Helper::TOKEN_REGEX) do |match|
          token = match[0]
          prefixes[token[0, 3]] << {token, model_index}
        end
      end
      prefixes
    end

    private def self.rule_matches?(
      rule : MobileRule,
      prefixes : Hash(String, Array(ModelCandidate)),
      user_agent : String,
    ) : Bool
      return false unless Helper.regex(rule.regex) =~ user_agent
      return true if rule.is_a?(SingleModelMobile)

      candidates = model_candidates(prefixes, user_agent)
      candidates.each do |model_index|
        return true if Helper.regex(rule.models[model_index].regex) =~ user_agent
      end

      # The generated token shortcut is an optimization, not a semantic gate.
      # Fall back to the remaining rules so the result stays parser-equivalent.
      candidate_set = candidates.to_set
      rule.models.each_with_index do |model, model_index|
        next if candidate_set.includes?(model_index)
        return true if Helper.regex(model.regex) =~ user_agent
      end

      false
    end

    private def self.model_candidates(
      prefixes : Hash(String, Array(ModelCandidate)),
      user_agent : String,
    ) : Array(Int32)
      candidates = Set(Int32).new
      user_agent.downcase.scan(Helper::TOKEN_REGEX) do |match|
        token = match[0]
        next if token.size < 3
        next unless indexed = prefixes[token[0, 3]]?

        indexed.each do |prefix, model_index|
          candidates << model_index if token.starts_with?(prefix) || prefix.starts_with?(token)
        end
      end
      candidates.to_a.sort!
    end

    def android_model_shortcut
      model = nil.as(String?)

      if match = @user_agent.match(ANDROID_BUILD_MODEL_REGEX)
        model = match[1]?
      elsif match = @user_agent.match(APP_DEVICE_MODEL_REGEX)
        model = match[1]?.try(&.gsub('_', ' '))
      end

      return nil unless model

      ANDROID_MODEL_SHORTCUTS[model.strip]?
    end

    def detect_mobile(vendor, device, detected_device)
      # --> If device has many models
      if device.is_a?(MultiModelMobile)
        if regex(device.regex) =~ @user_agent
          device.models.each do |model|
            if regex(model.regex) =~ @user_agent
              # Fill known keys
              detected_device.merge!({"vendor" => vendor})
              detected_device.merge!({"type" => device.type.to_s})
              # If model name contains capture groups
              if capture_groups?(model.model)
                model_name = fill_groups(model.model, model.regex, @user_agent)
                detected_device.merge!({"model" => model_name})
              else
                detected_device.merge!({"model" => model.model})
              end
              break
            end
          end
        end
      end

      # --> If device has one model
      if device.is_a?(SingleModelMobile)
        if regex(device.regex) =~ @user_agent
          # Fill known keys
          detected_device.merge!({"vendor" => vendor})
          detected_device.merge!({"type" => device.type.to_s})
          # If model name contains capture groups
          if capture_groups?(device.model)
            model = fill_groups(device.model, device.regex, @user_agent)
            detected_device.merge!({"model" => model})
          else
            detected_device.merge!({"model" => device.model})
          end
        end
      end
    end

    def call
      detected_device = {"device" => "", "vendor" => "", "type" => ""}
      return detected_device unless MOBILE_HINTS =~ @user_agent

      if match = @user_agent.match(APPLE_DEVICE_REGEX)
        model = match[1]
        detected_device["vendor"] = "Apple"
        detected_device["model"] = model
        detected_device["type"] = model == "iPad" ? "tablet" : "smartphone"
        return detected_device
      end

      if shortcut = android_model_shortcut
        detected_device["vendor"] = shortcut[0]
        detected_device["type"] = shortcut[1]
        detected_device["model"] = shortcut[2]
        return detected_device
      end

      token_candidates(mobile_index, @user_agent).each do |rule_index|
        next unless mobile = mobile_entries[rule_index]?

        candidate_device = {"device" => "", "vendor" => "", "type" => ""}
        detect_mobile(mobile[0], mobile[1], candidate_device)
        next if candidate_device["vendor"].blank?

        mobile_entries.each_with_index do |earlier_mobile, earlier_index|
          break if earlier_index >= rule_index
          detect_mobile(earlier_mobile[0], earlier_mobile[1], detected_device)
          return detected_device unless detected_device["vendor"].blank?
        end

        return candidate_device
      end

      mobile_entries.each do |mobile|
        # Shortcuts
        vendor = mobile[0]
        device = mobile[1]

        detect_mobile(vendor, device, detected_device)
        break unless detected_device["vendor"].blank?
      end
      detected_device
    end
  end
end
