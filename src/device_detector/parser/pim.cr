module DeviceDetector::Parser
  struct PIM
    include Helper
    
    getter kind = "pim"
    @@pims = Array(PIM).from_yaml(Storage.get("pim.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct PIM
      YAML.mapping(
        regex: String,
        name: String,
        version: String
      )
    end

    def pims
      return @@pims if @@pims
      @@pims = Array(PIM).from_yaml(Storage.get("pim.yml").gets_to_end)
    end

    def call
      detected_pim = {"name" => "", "version" => ""}
      pims.reverse_each do |pim|
        if Regex.new(pim.regex, Setting::REGEX_OPTS) =~ @user_agent
          detected_pim.merge!({"name" => pim.name})
          if capture_groups?(pim.version)
            version = fill_groups(pim.version, pim.regex, @user_agent)
            detected_pim.merge!({"version" => version})
          else
            detected_pim.merge!({"version" => pim.version})
          end
        end
      end
      detected_pim
    end
  end
end
