module DeviceDetector::Parser
  struct OS
    include Helper

    getter kind = "os"
    @@os = Array(OS).from_yaml(Storage.get("oss.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct OS
      YAML.mapping(
        regex: String,
        name: String,
        version: String
      )
    end

    def os
      return @@os if @@os
      @@os = Array(OS).from_yaml(Storage.get("oss.yml").gets_to_end)
    end

    def call
      detected_os = {"name" => "", "version" => ""}
      os.reverse_each do |os|
        if Regex.new(os.regex, Setting::REGEX_OPTS) =~ @user_agent
          # If name contains capture groups
          if capture_groups?(os.name)
            name = fill_groups(os.name, os.regex, @user_agent)
            detected_os.merge!({"name" => name})
          else
            detected_os.merge!({"name" => os.name})
          end
          # If version contains capture groups
          if capture_groups?(os.version)
            version = fill_groups(os.version, os.regex, @user_agent)
            detected_os.merge!({"version" => version})
          else
            detected_os.merge!({"version" => os.version})
          end
        end
      end
      detected_os
    end
  end
end
