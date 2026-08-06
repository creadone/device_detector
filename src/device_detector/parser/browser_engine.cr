module DeviceDetector::Parser
  struct BrowserEngine
    getter kind = "browser_engine"
    @@engines = Array(Engine).from_yaml(Storage.get("browser_engine.yml"))
    @@overall_pattern : String = @@engines.map(&.regex).join("|")

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Engine
      include YAML::Serializable

      property regex : String
      property name : String
    end

    def engines : Array(Engine)
      @@engines
    end

    def overall_regex : Regex
      Helper.regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = @@engines.map(&.regex)
      patterns << @@overall_pattern
    end

    # Compiles all browser-engine rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
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
