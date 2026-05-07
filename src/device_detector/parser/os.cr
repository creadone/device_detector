module DeviceDetector::Parser
  struct OS
    include Helper

    getter kind = "os"
    @@os = Array(OS).from_yaml(Storage.get("oss.yml"))

    WINDOWS_NT_REGEX    = /Windows NT (\d+\.\d+)/i
    WINDOWS_NT_VERSIONS = {
      "10.0" => "10",
      "6.4"  => "10",
      "6.3"  => "8.1",
      "6.2"  => "8",
      "6.1"  => "7",
      "6.0"  => "Vista",
      "5.2"  => "Server 2003",
      "5.1"  => "XP",
      "5.0"  => "2000",
      "4.0"  => "NT",
    }

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct OS
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def os
      return @@os if @@os
      @@os = Array(OS).from_yaml(Storage.get("oss.yml"))
    end

    def call
      detected_os = {"name" => "", "version" => ""}

      if match = @user_agent.match(WINDOWS_NT_REGEX)
        detected_os["name"] = "Windows"
        detected_os["version"] = WINDOWS_NT_VERSIONS[match[1]]? || "NT"
        return detected_os
      end

      os.reverse_each do |operating_system|
        if regex(operating_system.regex) =~ @user_agent
          # If name contains capture groups
          if capture_groups?(operating_system.name)
            name = fill_groups(operating_system.name, operating_system.regex, @user_agent)
            detected_os.merge!({"name" => name})
          else
            detected_os.merge!({"name" => operating_system.name})
          end
          # If version contains capture groups
          if capture_groups?(operating_system.version.to_s)
            version = fill_groups(operating_system.version.to_s, operating_system.regex, @user_agent)
            detected_os.merge!({"version" => version})
          else
            detected_os.merge!({"version" => operating_system.version.to_s})
          end
          break unless detected_os["version"].blank?
        end
      end
      detected_os
    end
  end
end
