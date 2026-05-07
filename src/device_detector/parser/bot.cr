module DeviceDetector::Parser
  struct Bot
    include Helper

    getter kind = "bot"
    @@bots = Array(Bot).from_yaml(Storage.get("bots.yml"))

    BOT_HINTS = /bot|crawl|spider|archiver|checker|monitor|fetcher|indexer|scanner|scraper|search|validator/i

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
      @@bots = Array(Bot).from_yaml(Storage.get("bots.yml"))
    end

    def call
      detected_bot = {"name" => ""}
      return detected_bot if human_browser?(@user_agent) && !(BOT_HINTS =~ @user_agent)

      bots.reverse_each do |bot|
        if regex(bot.regex) =~ @user_agent
          detected_bot.merge!({"name" => bot.name})
        end
      end
      detected_bot
    end
  end
end
