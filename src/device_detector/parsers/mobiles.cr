module DeviceDetector
  class MobileStore
    include Helper

    getter kind = "mobile"

    def initialize(user_agent : String)
      @mobiles = Hash(String, SingleModelMobile | MultiModelMobile)
        .from_yaml(Storage.get("mobiles.yml").gets_to_end)
      @user_agent = user_agent
    end

    class SingleModelMobile
      YAML.mapping(
        regex: String,
        type: {type: String?, key: "device", presence: true},
        model: String
      )
    end

    class MultiModelMobile
      YAML.mapping(
        regex: String,
        type: {type: String?, key: "device", presence: true},
        models: Array(SingleModelMobile)
      )
    end

    def call
      detected_device = {} of String => String
      @mobiles.each do |mobile|
        # Shortcats
        vendor = mobile[0]
        device = mobile[1]

        # --> If device has many models
        if device.is_a?(MultiModelMobile)
          device.models.each do |model|
            if Regex.new(model.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
              # Fill known keys
              detected_device.merge!({"vendor" => vendor})
              detected_device.merge!({"type" => device.type.not_nil!}) if device.type_present?
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
          if Regex.new(device.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
            # Fill known keys
            detected_device.merge!({"vendor" => vendor})
            detected_device.merge!({"type" => device.type.not_nil!}) if device.type_present?
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
