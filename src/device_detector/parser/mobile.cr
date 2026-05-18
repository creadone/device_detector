module DeviceDetector::Parser
  struct Mobile
    include Helper

    getter kind = "mobile"
    @@mobiles = Hash(String, SingleModelMobile | MultiModelMobile).from_yaml(Storage.get("mobiles.yml"))
    @@mobile_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/mobiles.yml"))
    @@mobile_entries = nil.as(Array(Tuple(String, SingleModelMobile | MultiModelMobile))?)

    MOBILE_HINTS              = /Mobile|Mobi|Android|iPhone|iPad|iPod|Windows Phone|BlackBerry|BB10|Opera Mini|Opera Mobi|IEMobile|Kindle|Silk|webOS|Tizen|KaiOS|Maemo|MeeGo|Symbian|PlayBook|Tablet|Phone|MIDP|CLDC|Nokia|Samsung|SonyEricsson|HTC|Huawei/i
    APPLE_DEVICE_REGEX        = /\b(iPhone|iPad|iPod)\b/i
    ANDROID_BUILD_MODEL_REGEX = /Android [^;]+; ([^;)]+?)(?: Build|[;)])/i
    APP_DEVICE_MODEL_REGEX    = /Device\/([^\s;)]+)/i
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
