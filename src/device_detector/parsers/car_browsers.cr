module DeviceDetector
  class CarBrowserStore
    include Helper

    getter kind = "car_browser"

    def initialize(user_agent : String)
      @car_browsers = Hash(String, SingleModelBrowser).from_yaml(Storage.get("car_browsers.yml").gets_to_end)
      @user_agent = user_agent
    end

    class SingleModelBrowser
      YAML.mapping(
        regex: String,
        device: String,
        model: String
      )
    end

    def call
      detected_car_browser = {"vendor" => "", "device" => "", "model" => ""}
      @car_browsers.each do |item|
        vendor = item[0]
        browser = item[1]
        if Regex.new(browser.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
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
