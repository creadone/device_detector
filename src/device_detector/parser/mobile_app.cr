module DeviceDetector::Parser
  struct MobileApp
    include Helper

    getter kind = "mobile_app"
    @@mobile_apps = Array(MobileApp).from_yaml(Storage.get("mobile_apps.yml"))
    @@overall_pattern : String = @@mobile_apps.map(&.regex).join("|")

    MOBILE_APP_HINTS = /Mobile|Mobi|Android|iPhone|iPad|iPod|Windows Phone|CFNetwork|Darwin|FBAN|FBAV|WhatsApp|Instagram|Telegram|Twitter|Line\//i

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct MobileApp
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def mobile_apps : Array(MobileApp)
      @@mobile_apps
    end

    def overall_regex : Regex
      regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = @@mobile_apps.map(&.regex)
      patterns << @@overall_pattern
    end

    # Compiles all mobile-app rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_app = {"name" => "", "version" => ""}
      return detected_app unless MOBILE_APP_HINTS =~ @user_agent
      return detected_app unless overall_regex =~ @user_agent

      mobile_apps.each do |app|
        if regex(app.regex) =~ @user_agent
          # -> If name contains capture groups
          if capture_groups?(app.name)
            name = fill_groups(app.name, app.regex, @user_agent)
            detected_app.merge!({"name" => name})
          else
            detected_app.merge!({"name" => app.name})
          end
          # -> If version contains capture groups
          if capture_groups?(app.version.to_s)
            version = fill_groups(app.version.to_s, app.regex, @user_agent)
            detected_app.merge!({"version" => version.to_s})
          else
            detected_app.merge!({"version" => app.version.to_s})
          end
          break
        end
      end
      detected_app
    end
  end
end
