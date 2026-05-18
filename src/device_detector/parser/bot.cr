module DeviceDetector::Parser
  struct Bot
    include Helper

    getter kind = "bot"
    @@bots = Array(Bot).from_yaml(Storage.get("bots.yml"))
    @@bot_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/bots.yml"))

    BOT_HINTS   = /bot|crawl|spider|archiver|checker|monitor|fetcher|indexer|scanner|scraper|search|validator/i
    COMMON_BOTS = {
      "Googlebot"   => "Googlebot",
      "Bingbot"     => "BingBot",
      "bingbot"     => "BingBot",
      "DuckDuckBot" => "DuckDuckBot",
      "AhrefsBot"   => "aHrefs Bot",
      "SemrushBot"  => "SemrushBot",
      "MJ12bot"     => "MJ12 Bot",
      "DotBot"      => "DotBot",
    }

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

    def bot_index
      return @@bot_index if @@bot_index
      @@bot_index = Hash(String, Array(Int32)).from_yaml(Storage.get("index/bots.yml"))
    end

    def detect_bot(bot, detected_bot)
      return false unless regex(bot.regex) =~ @user_agent

      detected_bot.merge!({"name" => bot.name})
      true
    end

    def call
      detected_bot = {"name" => ""}
      return detected_bot if human_browser?(@user_agent) && !(BOT_HINTS =~ @user_agent)

      COMMON_BOTS.each do |token, name|
        if @user_agent.includes?(token)
          detected_bot["name"] = name
          return detected_bot
        end
      end

      token_candidates(bot_index, @user_agent).each do |rule_index|
        next unless bot = bots[rule_index]?

        candidate_bot = {"name" => ""}
        next unless detect_bot(bot, candidate_bot)

        bots.each_with_index do |earlier_bot, earlier_index|
          break if earlier_index >= rule_index
          return detected_bot if detect_bot(earlier_bot, detected_bot)
        end

        return candidate_bot
      end

      bots.each do |bot|
        break if detect_bot(bot, detected_bot)
      end
      detected_bot
    end
  end
end
