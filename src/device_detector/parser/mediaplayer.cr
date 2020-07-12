module DeviceDetector::Parser
  struct Mediaplayer
    include Helper

    getter kind = "mediaplayer"
    @@mediaplayers = Array(Mediaplayer).from_yaml(Storage.get("mediaplayers.yml"))

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Mediaplayer
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String
    end

    def mediaplayers
      return @@mediaplayers if @@mediaplayers
      @@mediaplayers = Array(Mediaplayer).from_yaml(Storage.get("mediaplayers.yml"))
    end

    def call
      detected_player = {"name" => "", "version" => ""}
      mediaplayers.each do |player|
        if Regex.new(player.regex, Setting::REGEX_OPTS) =~ @user_agent
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
