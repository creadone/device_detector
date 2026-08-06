module DeviceDetector::Parser
  struct CarBrowser
    include Helper

    getter kind = "car_browser"
    @@car_browsers = Hash(String, MultiModelBrowser | SingleModelBrowser).from_yaml(Storage.get("car_browsers.yml"))
    @@overall_pattern : String = @@car_browsers.values.map(&.regex).join("|")

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

      property regex : String
      property device : String
      property models : Array(SingleModelBrowser)
    end

    def car_browsers : Hash(String, MultiModelBrowser | SingleModelBrowser)
      @@car_browsers
    end

    def overall_regex : Regex
      regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = [@@overall_pattern]
      @@car_browsers.each_value do |browser|
        patterns << browser.regex
        if browser.is_a?(MultiModelBrowser)
          browser.models.each { |model| patterns << model.regex }
        end
      end
      patterns
    end

    # Compiles all car-browser rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_car_browser = {"vendor" => "", "device" => "", "model" => ""}
      return detected_car_browser unless overall_regex =~ @user_agent

      car_browsers.each do |item|
        vendor = item[0]
        browser = item[1]

        if browser.is_a?(SingleModelBrowser)
          if regex(browser.regex) =~ @user_agent
            detected_car_browser.merge!({
              "vendor" => vendor,
              "model"  => browser.model,
            })
          end
        end

        if browser.is_a?(MultiModelBrowser)
          if regex(browser.regex) =~ @user_agent
            browser.models.each do |model|
              if regex(model.regex) =~ @user_agent
                detected_car_browser.merge!({"vendor" => vendor, "device" => browser.device})
                if capture_groups?(model.model)
                  filled_name = fill_groups(model.model, model.regex, @user_agent)
                  detected_car_browser.merge!({"model" => filled_name})
                else
                  detected_car_browser.merge!({"model" => model.model})
                end
                break
              end
            end
          end
        end
        break unless detected_car_browser["vendor"].blank?
      end

      detected_car_browser
    end
  end
end
