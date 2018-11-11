module DeviceDetector
  struct MobileStore
    include Helper
    getter kind = "mobile"
    @@mobiles = Hash(String, SingleModelMobile | MultiModelMobile).from_yaml(Storage.get("mobiles.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModelMobile
      YAML.mapping(
        regex: String,
        type: {type: String?, key: "device", presence: true},
        model: String
      )
    end

    struct MultiModelMobile
      YAML.mapping(
        regex: String,
        type: {type: String?, key: "device", presence: true},
        models: Array(SingleModelMobile)
      )
    end

    def mobiles
      return @@mobiles if @@mobiles
      @@mobiles = Hash(String, SingleModelMobile | MultiModelMobile).from_yaml(Storage.get("mobiles.yml").gets_to_end)
    end

    def call
      detected_device = {"device" => "", "vendor" => "", "type" => ""}
      mobiles.each do |mobile|
        # Shortcats
        vendor = mobile[0]
        device = mobile[1]

        # --> If device has many models
        if device.is_a?(MultiModelMobile)
          device.models.each do |model|
            if Regex.new(model.regex, Settings::REGEX_OPTS) =~ @user_agent
              # Fill known keys
              detected_device.merge!({"vendor" => vendor})
              detected_device.merge!({"type" => device.type.to_s})
              # If model name contains cature groups
              if capture_groups?(model.model)
                model_name = fill_groups(model.model, model.regex, @user_agent)
                detected_device.merge!({"model" => model_name})
              else
                detected_device.merge!({"model" => model.model})
              end
            end
          end
        end

        # --> If device has one model
        if device.is_a?(SingleModelMobile)
          if Regex.new(device.regex, Settings::REGEX_OPTS) =~ @user_agent
            # Fill known keys
            detected_device.merge!({"vendor" => vendor})
            detected_device.merge!({"type" => device.type.to_s})
            # If model name contains cature groups
            if capture_groups?(device.model)
              model = fill_groups(device.model, device.regex, @user_agent)
              detected_device.merge!({"model" => model})
            else
              detected_device.merge!({"model" => device.model})
            end
          end
        end
      end
      detected_device
    end
  end
end
