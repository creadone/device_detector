module DeviceDetector
  class CameraStore
    include Helper

    getter kind = "camera"

    def initialize(user_agent : String)
      @cameras = Hash(String, SingleModel | MultiModel)
        .from_yaml(Storage.get("cameras.yml").gets_to_end)
      @user_agent = user_agent
    end

    class SingleModel
      YAML.mapping(
        regex: String,
        device: {type: String?, presence: true},
        name: {type: String, key: "model"}
      )
    end

    class MultiModel
      YAML.mapping(
        regex: String,
        device: String,
        models: Array(SingleModel)
      )
    end

    def call
      detected_camera = {"vendor" => "", "model" => "", "device" => ""}
      @cameras.to_a.reverse.to_h.each do |camera|
        # Shortcats
        vendor = camera[0]
        device = camera[1]

        # --> If device has many models
        if device.is_a?(MultiModel)
          device.models.each do |model|
            if Regex.new(model.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
              detected_camera.merge!({"vendor" => vendor})
              if capture_groups?(model.name)
                filled_name = fill_groups(model.name, model.regex, @user_agent)
                detected_camera.merge!({"model" => filled_name})
              else
                detected_camera.merge!({"model" => model.name})
              end
            end
          end
        end

        # --> If device has one model
        if device.is_a?(SingleModel)
          if Regex.new(device.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
            detected_camera.merge!({"vendor" => vendor, "device" => device.name})
          end
        end
      end
      detected_camera
    end
  end
end
