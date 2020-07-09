module DeviceDetector::Parser
  struct Bot
    getter kind = "bot"
    @@bots = Array(Bot).from_yaml(Storage.get("bots.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Bot
      include YAML::Serializable

      property regex : String
      property name : String
      property category : String?
    end

    def bots
      return @@bots if @@bots
      @@bots = Array(Bot).from_yaml(Storage.get("bots.yml").gets_to_end)
    end

    def call
      detected_bot = {"name" => ""}
      bots.reverse_each do |bot|
        if Regex.new(bot.regex, Setting::REGEX_OPTS) =~ @user_agent
          detected_bot.merge!({"name" => bot.name})
        end
      end
      detected_bot
    end
  end
end
