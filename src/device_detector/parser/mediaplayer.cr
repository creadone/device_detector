module DeviceDetector::Parser
  struct Mediaplayer
    include Helper

    getter kind = "mediaplayer"
    @@mediaplayers = Array(Mediaplayer).from_yaml(Storage.get("mediaplayers.yml"))
    @@overall_regex = nil.as(Regex?)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Mediaplayer
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def mediaplayers
      return @@mediaplayers if @@mediaplayers
      @@mediaplayers = Array(Mediaplayer).from_yaml(Storage.get("mediaplayers.yml"))
    end

    def overall_regex
      @@overall_regex ||= regex(mediaplayers.map(&.regex).join("|"))
    end

    def call
      detected_player = {"name" => "", "version" => ""}
      return detected_player unless overall_regex =~ @user_agent

      mediaplayers.each do |player|
        if regex(player.regex) =~ @user_agent
          detected_player.merge!({"name" => player.name})
          if capture_groups?(player.version.to_s)
            version = fill_groups(player.version.to_s, player.regex, @user_agent)
            detected_player.merge!({"version" => version})
          else
            detected_player.merge!({"version" => player.version.to_s})
          end
          break
        end
      end
      detected_player
    end
  end
end
