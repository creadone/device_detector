module DeviceDetector::Parser
  struct Camera
    include Helper

    getter kind = "camera"
    @@cameras = Hash(String, SingleModel | MultiModel).from_yaml(Storage.get("cameras.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModel
      YAML.mapping(
        regex: String,
        device: {type: String?, presence: true},
        name: {type: String, key: "model"}
      )
    end

    struct MultiModel
      YAML.mapping(
        regex: String,
        device: String,
        models: Array(SingleModel)
      )
    end

    def cameras
      return @@cameras if @@cameras
      @@cameras = Hash(String, SingleModel | MultiModel).from_yaml(Storage.get("cameras.yml").gets_to_end)
    end

    def call
      detected_camera = {"vendor" => "", "model" => "", "device" => ""}
      cameras.to_a.reverse.to_h.each do |camera|
        # Shortcats
        vendor = camera[0]
        device = camera[1]

        # If device has many models
        if device.is_a?(MultiModel)
          if Regex.new(device.regex) =~ @user_agent
            device.models.each do |model|
              if Regex.new(model.regex, Setting::REGEX_OPTS) =~ @user_agent
                detected_camera["vendor"] = vendor

                if capture_groups?(model.name)
                  filled_name = fill_groups(model.name, model.regex, @user_agent)
                  detected_camera["model"] = filled_name
                else
                  detected_camera["model"] = model.name
                end
              end
            end
          end
        end

        # If device has one model
        if device.is_a?(SingleModel)
          if Regex.new(device.regex, Setting::REGEX_OPTS) =~ @user_agent
            detected_camera["vendor"] = vendor
            detected_camera["device"] = device.name
          end
        end
      end

      detected_camera
    end
  end
end
