module DeviceDetector
  class BrowserStore
    include Helper

    getter kind = "browser"

    def initialize(user_agent : String)
      @browsers = Array(Browser).from_yaml(Storage.get("browsers.yml").gets_to_end)
      @user_agent = user_agent
    end

    class Browser
      YAML.mapping(
        regex: String,
        name: String,
        version: {
          type:     (String | Int32 | Float32),
          nilable:  true,
          presence: true,
        }
      )
    end

    def call
      detected_browser = {"name" => "", "version" => ""}
      @browsers.reverse_each do |browser|
        if Regex.new(browser.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
          detected_browser.merge!({"name" => browser.name})
          if browser.version_present?
            if capture_groups?(browser.version.to_s)
              version = fill_groups(browser.version.to_s, browser.regex, @user_agent)
              detected_browser.merge!({"version" => version})
            else
              detected_browser.merge!({"version" => browser.version.to_s})
            end
          end
        end
      end
      detected_browser
    end
  end
end
