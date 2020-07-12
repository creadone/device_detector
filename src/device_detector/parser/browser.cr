module DeviceDetector::Parser
  struct Browser
    include Helper

    getter kind = "browser"
    @@browsers = Array(Browser).from_yaml(Storage.get("browsers.yml"))

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Browser
      include YAML::Serializable

      property regex : String
      property name : String
      property version : (String | Int32 | Float32)?
    end

    def browsers
      return @@browsers if @@browsers
      @@browsers = Array(Browser).from_yaml(Storage.get("browsers.yml"))
    end

    def call
      detected_browser = {"name" => "", "version" => ""}
      browsers.reverse_each do |browser|
        if Regex.new(browser.regex, Setting::REGEX_OPTS) =~ @user_agent
          detected_browser.merge!({"name" => browser.name})
          if version = browser.version
            if capture_groups?(version.to_s)
              version = fill_groups(version.to_s, browser.regex, @user_agent)
              detected_browser.merge!({"version" => version})
            else
              detected_browser.merge!({"version" => version.to_s})
            end
          end
        end
      end
      detected_browser
    end
  end
end
