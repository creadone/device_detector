module DeviceDetector
  struct PIMStore
    include Helper

    getter kind = "pim"

    def initialize(user_agent : String)
      @pims = Array(PIM).from_yaml(Storage.get("pim.yml").gets_to_end)
      @user_agent = user_agent
    end

    struct PIM
      YAML.mapping(
        regex: String,
        name: String,
        version: String
      )
    end

    def call
      detected_pim = {"name" => "", "version" => ""}
      @pims.reverse_each do |pim|
        if Regex.new(pim.regex, Settings::REGEX_OPTS) =~ @user_agent
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
