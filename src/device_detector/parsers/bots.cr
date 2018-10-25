module DeviceDetector
  class BotStore
    getter kind = "bot"

    def initialize(user_agent : String)
      @bots = Array(Bot).from_yaml(Storage.get("bots.yml").gets_to_end)
      @user_agent = user_agent
    end

    class Bot
      YAML.mapping(
        regex: String,
        name: String,
        category: {type: String, nilable: true, presence: true},
      )
    end

    def call
      detected_bot = {"name" => ""}
      @bots.reverse_each do |bot|
        if Regex.new(bot.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
          detected_bot.merge!({"name" => bot.name})
        end
      end
      detected_bot
    end
  end
end
