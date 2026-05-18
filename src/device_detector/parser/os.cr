module DeviceDetector::Parser
  struct OS
    include Helper

    getter kind = "os"
    @@os = Array(OS).from_yaml(Storage.get("oss.yml"))
    @@os_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/oss.yml"))

    WINDOWS_NT_REGEX    = /Windows NT (\d+\.\d+)/i
    ANDROID_REGEX       = /Android[ ;\/](\d+[.\d]*)/i
    IOS_REGEX           = /(?:CPU OS|iPh(?:one)?[ _]OS|iPhone.+ OS|iOS)[ _\/](\d+(?:[_.]\d+)*)/i
    MACOS_REGEX         = /Mac[ +]OS[ +]?X(?:[ \/,](?:Version )?(\d+(?:[_.]\d+)+))?/i
    GENERIC_LINUX_REGEX = /X11; Linux|Linux (?:x86_64|i686|aarch64|armv7l)/i
    LINUX_DISTRO_HINTS  = /Fedora|Ubuntu|Debian|CentOS|Red Hat|RHEL|Gentoo|Arch Linux|SUSE|Mandriva|Mageia|Mint/i
    ANDROID_TV_HINTS    = /(?:Android(?: UHD)?|Smart)[ _]?TV|AndroidTV|GoogleTV|BRAVIA|wv-atv/i
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

    def os_index
      return @@os_index if @@os_index
      @@os_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/oss.yml"))
    end

    def os_result(name, version = "")
      {"name" => name, "version" => version}
    end

    def windows_nt_os
      return nil unless match = @user_agent.match(WINDOWS_NT_REGEX)

      os_result("Windows", WINDOWS_NT_VERSIONS[match[1]]? || "NT")
    end

    def android_os
      return nil if ANDROID_TV_HINTS =~ @user_agent
      return nil unless match = @user_agent.match(ANDROID_REGEX)

      os_result("Android", match[1]? || "")
    end

    def ios_os
      return nil unless match = @user_agent.match(IOS_REGEX)

      os_result("iOS", (match[1]? || "").tr("_", "."))
    end

    def macos_os
      return nil unless match = @user_agent.match(MACOS_REGEX)

      os_result("Mac", match[1]? || "")
    end

    def generic_linux_os
      return nil unless GENERIC_LINUX_REGEX =~ @user_agent
      return nil if LINUX_DISTRO_HINTS =~ @user_agent

      os_result("GNU/Linux")
    end

    def common_os
      windows_nt_os || android_os || ios_os || macos_os || generic_linux_os
    end

    def detect_os(operating_system, detected_os)
      return false unless regex(operating_system.regex) =~ @user_agent

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

      !detected_os["version"].blank?
    end

    def call
      detected_os = {"name" => "", "version" => ""}
      if detected = common_os
        return detected
      end

      token_candidates(os_index, @user_agent, reverse: true).each do |rule_index|
        next unless operating_system = os[rule_index]?

        candidate_os = {"name" => "", "version" => ""}
        next unless detect_os(operating_system, candidate_os)

        (rule_index + 1...os.size).reverse_each do |earlier_index|
          return detected_os if detect_os(os[earlier_index], detected_os)
        end

        return candidate_os
      end

      os.reverse_each do |operating_system|
        break if detect_os(operating_system, detected_os)
      end
      detected_os
    end
  end
end
