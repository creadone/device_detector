module DeviceDetector::Parser
  struct BrowserEngine
    getter kind = "browser_engine"
    @@engines = Array(Engine).from_yaml(Storage.get("browser_engine.yml"))
    @@overall_regex = nil.as(Regex?)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Engine
      include YAML::Serializable

      property regex : String
      property name : String
    end

    def engines
      return @@engines if @@engines
      @@engines = Array(Engine).from_yaml(Storage.get("browser_engine.yml"))
    end

    def overall_regex
      @@overall_regex ||= Helper.regex(engines.map(&.regex).join("|"))
    end

    def call
      detected_engine = {"name" => ""}
      return detected_engine unless overall_regex =~ @user_agent

      engines.each do |engine|
        if Helper.regex(engine.regex) =~ @user_agent
          detected_engine.merge!({"name" => engine.name})
          break
        end
      end
      detected_engine
    end
  end
end
