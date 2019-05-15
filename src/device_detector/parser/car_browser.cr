module DeviceDetector::Parser
  struct CarBrowser
    include Helper

    getter kind = "car_browser"
    @@car_browsers = Hash(String, SingleModelBrowser).from_yaml(Storage.get("car_browsers.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModelBrowser
      YAML.mapping(
        regex: String,
        device: String,
        model: String
      )
    end

    def car_browsers
      return @@car_browsers if @@car_browsers
      @@car_browsers = Hash(String, SingleModelBrowser).from_yaml(Storage.get("car_browsers.yml").gets_to_end)
    end

    def call
      detected_car_browser = {"vendor" => "", "device" => "", "model" => ""}
      car_browsers.each do |item|
        vendor = item[0]
        browser = item[1]
        if Regex.new(browser.regex, Setting::REGEX_OPTS) =~ @user_agent
          detected_car_browser.merge!({
            "vendor" => vendor,
            "device" => browser.device,
            "model"  => browser.model,
          })
        end
      end
      detected_car_browser
    end
  end
end
