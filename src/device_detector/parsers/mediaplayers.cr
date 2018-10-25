module DeviceDetector
  class MediaplayerStore
    include Helper

    getter kind = "mediaplayer"

    def initialize(user_agent : String)
      @mediaplayers = Array(Mediaplayer).from_yaml(Storage.get("mediaplayers.yml").gets_to_end)
      @user_agent = user_agent
    end

    class Mediaplayer
      YAML.mapping(
        regex: String,
        name: String,
        version: String
      )
    end

    def call
      detected_player = {"name" => "", "version" => ""}
      @mediaplayers.each do |player|
        if Regex.new(player.regex) =~ @user_agent
          detected_player.merge!({"name" => player.name})
          if capture_groups?(player.version)
            version = fill_groups(player.version, player.regex, @user_agent)
            detected_player.merge!({"version" => version})
          else
            detected_player.merge!({"version" => player.version})
          end
        end
      end
      detected_player
    end
  end
end
