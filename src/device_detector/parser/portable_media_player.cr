module DeviceDetector::Parser
  struct PortableMediaPlayer
    include Helper

    getter kind = "portable_media_player"
    @@media_players = Hash(String, SingleModelPlayer | MultiModelPlayer).from_yaml(Storage.get("portable_media_player.yml"))
    @@overall_pattern : String = @@media_players.values.map(&.regex).join("|")

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModelPlayer
      include YAML::Serializable

      property regex : String
      property device : String?
      property model : String
    end

    struct MultiModelPlayer
      include YAML::Serializable

      property regex : String
      property device : String
      property models : Array(SingleModelPlayer)
    end

    def media_players : Hash(String, SingleModelPlayer | MultiModelPlayer)
      @@media_players
    end

    def overall_regex : Regex
      regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = [@@overall_pattern]
      @@media_players.each_value do |device|
        patterns << device.regex
        if device.is_a?(MultiModelPlayer)
          device.models.each { |model| patterns << model.regex }
        end
      end
      patterns
    end

    # Compiles all portable-media-player rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_player = {"vendor" => "", "model" => ""}
      return detected_player unless overall_regex =~ @user_agent

      media_players.each do |item|
        vendor = item[0]
        device = item[1]

        # --> If device has many models
        if device.is_a?(MultiModelPlayer)
          if regex(device.regex) =~ @user_agent
            device.models.each do |model|
              if regex(model.regex) =~ @user_agent
                # Fill known keys
                detected_player.merge!({"vendor" => vendor})
                # If model name contains capture groups
                if capture_groups?(model.model)
                  model_name = fill_groups(model.model, model.regex, @user_agent)
                  detected_player.merge!({"model" => model_name})
                else
                  detected_player.merge!({"model" => model.model})
                end
                break
              end
            end
          end
        end

        # --> If device has one model
        if device.is_a?(SingleModelPlayer)
          if regex(device.regex) =~ @user_agent
            # Fill known keys
            detected_player.merge!({"vendor" => vendor})
            # If model name contains capture groups
            if capture_groups?(device.model)
              model = fill_groups(device.model, device.regex, @user_agent)
              detected_player.merge!({"model" => model})
            else
              detected_player.merge!({"model" => device.model})
            end
          end
        end
        break unless detected_player["vendor"].blank?
      end
      detected_player
    end
  end
end
