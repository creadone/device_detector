module DeviceDetector::Parser
  struct CarBrowser
    include Helper

    getter kind = "car_browser"
    @@car_browsers = Hash(String, MultiModelBrowser | SingleModelBrowser).from_yaml(Storage.get("car_browsers.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    #
    # Tesla:
    #   regex: '(?:Tesla/[0-9.]+|QtCarBrowser)'
    #   device: 'car browser'
    #   models:
    #     - regex: 'QtCarBrowser'
    #       model: 'Model S'
    #     - regex: 'Tesla/[0-9.]+'
    #       model: ''

    struct SingleModelBrowser
      include YAML::Serializable

      property regex : String
      property model : String
    end

    struct MultiModelBrowser
      include YAML::Serializable

      property regex  : String
      property device : String
      property models : Array(SingleModelBrowser)
    end

    def car_browsers
      return @@car_browsers if @@car_browsers
      @@car_browsers = Hash(String, MultiModelBrowser | SingleModelBrowser).from_yaml(Storage.get("car_browsers.yml").gets_to_end)
    end

    def call
      detected_car_browser = {"vendor" => "", "device" => "", "model" => ""}

      car_browsers.each do |item|
        vendor  = item[0]
        browser = item[1]

        if browser.is_a?(SingleModelBrowser)
          if Regex.new(browser.regex, Setting::REGEX_OPTS) =~ @user_agent
            detected_car_browser.merge!({
              "vendor" => vendor,
              "model"  => browser.model,
            })
          end
        end

        if browser.is_a?(MultiModelBrowser)
          if Regex.new(browser.regex) =~ @user_agent
            browser.models.each do |model|
              if Regex.new(model.regex, Setting::REGEX_OPTS) =~ @user_agent
                detected_car_browser.merge!({"vendor" => vendor, "device" => browser.device})
                if capture_groups?(model.model)
                  filled_name = fill_groups(model.model, model.regex, @user_agent)
                  detected_car_browser.merge!({"model" => filled_name})
                else
                  detected_car_browser.merge!({"model" => model.model})
                end
              end
            end
          end
        end
      end

      detected_car_browser
    end
  end
end
