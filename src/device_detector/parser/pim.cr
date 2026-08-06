module DeviceDetector::Parser
  struct PIM
    include Helper

    getter kind = "pim"
    @@pims = Array(PIM).from_yaml(Storage.get("pim.yml"))
    @@overall_pattern : String = @@pims.map(&.regex).join("|")

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct PIM
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def pims : Array(PIM)
      @@pims
    end

    def overall_regex : Regex
      regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = @@pims.map(&.regex)
      patterns << @@overall_pattern
    end

    # Compiles all PIM rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_pim = {"name" => "", "version" => ""}
      return detected_pim unless overall_regex =~ @user_agent

      pims.each do |pim|
        if regex(pim.regex) =~ @user_agent
          detected_pim.merge!({"name" => pim.name})
          if capture_groups?(pim.version.to_s)
            version = fill_groups(pim.version.to_s, pim.regex, @user_agent)
            detected_pim.merge!({"version" => version})
          else
            detected_pim.merge!({"version" => pim.version.to_s})
          end
          break
        end
      end
      detected_pim
    end
  end
end
