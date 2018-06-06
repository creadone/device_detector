module DeviceDetector
  class OSSStore
    include Helper

    getter kind = "oss"

    def initialize(user_agent : String)
      @oss = Array(OSS).from_yaml(Storage.get("oss.yml").gets_to_end)
      @user_agent = user_agent
    end

    class OSS
      YAML.mapping(
        regex: String,
        name: String,
        version: String
      )
    end

    def call
      detected_os = {} of String => String
      @oss.reverse_each do |os|
        if Regex.new(os.regex) =~ @user_agent
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
