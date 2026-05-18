module DeviceDetector::Parser
  struct Browser
    include Helper

    getter kind = "browser"
    @@browsers = Array(Browser).from_yaml(Storage.get("browsers.yml"))
    @@browser_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/browsers.yml"))

    BROWSER_HINTS      = /AppleWebKit|Chrome|Safari|Firefox|Edge|Edg|MSIE|Trident|Opera|OPR|YaBrowser|UCBrowser|SamsungBrowser|Vivaldi/i
    EDGE_SPARTAN_REGEX = /(?<!motorola )Edge[ \/](\d+[\.\d]+)/i
    YANDEX_REGEX       = /YaBrowser\/(\d+[.\d]*)/i
    FIREFOX_REGEX      = /Firefox[ \/](\d+[.\d]+)/i
    CHROME_REGEX       = /Chrome\/(\d+\.[.\d]+)/i
    SAFARI_REGEX       = /Version\/(\d+\.[.\d]+).*Safari\//i
    CHROME_FORK_HINTS  = /YaBrowser|Edg|Edge|OPR|Opera|SamsungBrowser|UCBrowser|DuckDuckGo|Brave|Vivaldi|Maxthon|MIUIBrowser|HuaweiBrowser|HeyTapBrowser|Quark|AlohaBrowser|Avast|CriOS|FxiOS|Chromium|HeadlessChrome|Version\/.*Chrome/i

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

    def browser_index
      return @@browser_index if @@browser_index
      @@browser_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/browsers.yml"))
    end

    def browser_result(name, version)
      {"name" => name, "version" => version}
    end

    def edge_spartan_browser
      return nil unless match = @user_agent.match(EDGE_SPARTAN_REGEX)

      browser_result("Microsoft Edge", match[1]? || "")
    end

    def yandex_browser
      return nil unless match = @user_agent.match(YANDEX_REGEX)

      browser_result("Yandex Browser", match[1]? || "")
    end

    def firefox_browser
      return nil unless match = @user_agent.match(FIREFOX_REGEX)

      name = @user_agent.match(/(?:Mobile|Tablet)/i) ? "Firefox Mobile" : "Firefox"
      browser_result(name, match[1]? || "")
    end

    def chrome_browser
      return nil if CHROME_FORK_HINTS =~ @user_agent
      return nil unless match = @user_agent.match(CHROME_REGEX)

      name = @user_agent.match(/Mobile/i) ? "Chrome Mobile" : "Chrome"
      browser_result(name, match[1]? || "")
    end

    def safari_browser
      return nil unless match = @user_agent.match(SAFARI_REGEX)

      name = @user_agent.match(/(?:iPod|iPad|iPhone|Mobile)/i) ? "Mobile Safari" : "Safari"
      browser_result(name, match[1]? || "")
    end

    def common_browser
      edge_spartan_browser || yandex_browser || firefox_browser || chrome_browser || safari_browser
    end

    def detect_browser(browser, detected_browser)
      return false unless regex(browser.regex) =~ @user_agent

      detected_browser.merge!({"name" => browser.name})
      if version = browser.version
        if capture_groups?(version.to_s)
          version = fill_groups(version.to_s, browser.regex, @user_agent)
          detected_browser.merge!({"version" => version})
        else
          detected_browser.merge!({"version" => version.to_s})
        end
      end

      true
    end

    def call
      detected_browser = {"name" => "", "version" => ""}
      return detected_browser unless BROWSER_HINTS =~ @user_agent

      if detected = common_browser
        return detected
      end

      token_candidates(browser_index, @user_agent).each do |rule_index|
        next unless browser = browsers[rule_index]?

        candidate_browser = {"name" => "", "version" => ""}
        next unless detect_browser(browser, candidate_browser)

        browsers.each_with_index do |earlier_browser, earlier_index|
          break if earlier_index >= rule_index
          return detected_browser if detect_browser(earlier_browser, detected_browser)
        end

        return candidate_browser
      end

      browsers.each do |browser|
        break if detect_browser(browser, detected_browser)
      end
      detected_browser
    end
  end
end
