module DeviceDetector
  class ConsoleStore
    include Helper

    getter kind = "console"

    def initialize(user_agent : String)
      @consoles = Hash(String, MultiModelConsole | SingleModelConsole)
        .from_yaml(Storage.get("consoles.yml").gets_to_end)
      @user_agent = user_agent
    end

    class SingleModelConsole
      YAML.mapping(
        regex: String,
        device: String?,
        model: String
      )
    end

    class MultiModelConsole
      YAML.mapping(
        regex: String,
        device: String,
        models: Array(SingleModelConsole)
      )
    end

    def call
      detected_console = {"vendor" => "", "model" => ""}
      @consoles.each do |console|
        vendor = console[0]
        device = console[1]

        # --> If device has many models
        if device.is_a?(MultiModelConsole)
          device.models.each do |model|
            if Regex.new(model.regex) =~ @user_agent
              detected_console.merge!({"vendor" => vendor})
              if capture_groups?(model.model)
                filled_name = fill_groups(model.model, model.regex, @user_agent)
                detected_console.merge!({"model" => filled_name})
              else
                detected_console.merge!({"model" => model.model})
              end
            end
          end
        end

        # --> If device has many models
        if device.is_a?(SingleModelConsole)
          if Regex.new(device.regex) =~ @user_agent
            detected_console.merge!({"vendor" => vendor})
            if capture_groups?(device.model)
              filled_name = fill_groups(device.model, device.regex, @user_agent)
              detected_console.merge!({"model" => filled_name})
            else
              detected_console.merge!({"model" => device.model})
            end
          end
        end
      end
      detected_console
    end
  end
end
