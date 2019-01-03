module DeviceDetector::Parser
  struct Television
    include Helper

    getter kind = "tv"
    @@tvs = Hash(String, SingleModelTV | MultiModelTV).from_yaml(Storage.get("television.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModelTV
      YAML.mapping(
        regex: String,
        model: String
      )
    end

    struct MultiModelTV
      YAML.mapping(
        regex: String,
        models: Array(SingleModelTV)
      )
    end

    def tvs
      return @@tvs if @@tvs
      @@tvs = Hash(String, SingleModelTV | MultiModelTV).from_yaml(Storage.get("television.yml").gets_to_end)
    end

    def call
      detected_tv = {"model" => "", "vendor" => ""}
      tvs.to_a.reverse.to_h.each do |item|
        vendor = item[0]
        device = item[1]

        # --> If device has many models
        if device.is_a?(MultiModelTV)
          device.models.each do |model|
            if Regex.new(model.regex, Setting::REGEX_OPTS) =~ @user_agent
              # Fill known keys
              detected_tv.merge!({"vendor" => vendor})
              # If model name contains capture groups
              if capture_groups?(model.model)
                model_name = fill_groups(model.model, model.regex, @user_agent)
                detected_tv.merge!({"model" => model_name})
              else
                detected_tv.merge!({"model" => model.model})
              end
            end
          end
        end

        # --> If device has one model
        if device.is_a?(SingleModelTV)
          if Regex.new(device.regex) =~ @user_agent
            # Fill known keys
            detected_tv.merge!({"vendor" => vendor})
            # If model name contains capture groups
            if capture_groups?(device.model)
              model = fill_groups(device.model, device.regex, @user_agent)
              detected_tv.merge!({"model" => model})
            else
              detected_tv.merge!({"model" => device.model})
            end
          end
        end
      end
      detected_tv
    end
  end
end
