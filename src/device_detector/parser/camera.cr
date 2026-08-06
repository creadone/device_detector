module DeviceDetector::Parser
  struct Camera
    include Helper

    getter kind = "camera"
    @@cameras = Hash(String, SingleModel | MultiModel).from_yaml(Storage.get("cameras.yml"))
    @@overall_pattern : String = @@cameras.values.map(&.regex).join("|")

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModel
      include YAML::Serializable

      property regex : String
      property device : String?

      @[YAML::Field(key: "model")]
      property name : String
    end

    struct MultiModel
      include YAML::Serializable

      property regex : String
      property device : String
      property models : Array(SingleModel)
    end

    def cameras : Hash(String, SingleModel | MultiModel)
      @@cameras
    end

    def overall_regex : Regex
      regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = [@@overall_pattern]
      @@cameras.each_value do |device|
        patterns << device.regex
        if device.is_a?(MultiModel)
          device.models.each { |model| patterns << model.regex }
        end
      end
      patterns
    end

    # Compiles all camera rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_camera = {"vendor" => "", "model" => "", "device" => ""}
      return detected_camera unless overall_regex =~ @user_agent

      cameras.to_a.reverse.to_h.each do |camera|
        # Shortcuts
        vendor = camera[0]
        device = camera[1]

        # If device has many models
        if device.is_a?(MultiModel)
          if regex(device.regex) =~ @user_agent
            device.models.each do |model|
              if regex(model.regex) =~ @user_agent
                detected_camera["vendor"] = vendor
                if capture_groups?(model.name)
                  filled_name = fill_groups(model.name, model.regex, @user_agent)
                  detected_camera["model"] = filled_name
                else
                  detected_camera["model"] = model.name
                end
                break
              end
            end
          end
        end

        # If device has one model
        if device.is_a?(SingleModel)
          if regex(device.regex) =~ @user_agent
            detected_camera["vendor"] = vendor
            detected_camera["device"] = device.name
          end
        end
        break unless detected_camera["vendor"].blank?
      end

      detected_camera
    end
  end
end
