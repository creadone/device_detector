module DeviceDetector::Parser
  struct Console
    include Helper

    getter kind = "console"
    @@consoles = Hash(String, MultiModelConsole | SingleModelConsole).from_yaml(Storage.get("consoles.yml"))
    @@overall_pattern : String = @@consoles.values.map(&.regex).join("|")

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModelConsole
      include YAML::Serializable

      property regex : String
      property device : String?
      property model : String
    end

    struct MultiModelConsole
      include YAML::Serializable

      property regex : String
      property device : String
      property models : Array(SingleModelConsole)
    end

    def consoles : Hash(String, MultiModelConsole | SingleModelConsole)
      @@consoles
    end

    def overall_regex : Regex
      regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = [@@overall_pattern]
      @@consoles.each_value do |device|
        patterns << device.regex
        if device.is_a?(MultiModelConsole)
          device.models.each { |model| patterns << model.regex }
        end
      end
      patterns
    end

    # Compiles all console rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_console = {"vendor" => "", "model" => ""}
      return detected_console unless overall_regex =~ @user_agent

      consoles.each do |console|
        vendor = console[0]
        device = console[1]

        # --> If device has many models
        if device.is_a?(MultiModelConsole)
          if regex(device.regex) =~ @user_agent
            device.models.each do |model|
              if regex(model.regex) =~ @user_agent
                detected_console.merge!({"vendor" => vendor})
                if capture_groups?(model.model)
                  filled_name = fill_groups(model.model, model.regex, @user_agent)
                  detected_console.merge!({"model" => filled_name})
                else
                  detected_console.merge!({"model" => model.model})
                end
                break
              end
            end
          end
        end

        # --> If device has many models
        if device.is_a?(SingleModelConsole)
          if regex(device.regex) =~ @user_agent
            detected_console.merge!({"vendor" => vendor})
            if capture_groups?(device.model)
              filled_name = fill_groups(device.model, device.regex, @user_agent)
              detected_console.merge!({"model" => filled_name})
            else
              detected_console.merge!({"model" => device.model})
            end
          end
        end
        break unless detected_console["vendor"].blank?
      end
      detected_console
    end
  end
end
