module DeviceDetector::Parser
  struct Browser
    include Helper

    getter kind = "browser"
    @@browsers = Array(Browser).from_yaml(Storage.get("browsers.yml"))

    EDGE_SPARTAN_REGEX = /(?<!motorola )Edge[ \/](\d+[\.\d]+)/i

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

      if match = @user_agent.match(EDGE_SPARTAN_REGEX)
        detected_browser["name"] = "Microsoft Edge"
        detected_browser["version"] = match[1]? || ""
        return detected_browser
      end

      browsers.reverse_each do |browser|
        if regex(browser.regex) =~ @user_agent
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
