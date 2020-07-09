module DeviceDetector::Parser
  struct MobileApp
    include Helper

    getter kind = "mobile_app"
    @@mobile_apps = Array(MobileApp).from_yaml(Storage.get("mobile_apps.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct MobileApp
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def mobile_apps
      return @@mobile_apps if @@mobile_apps
      @@mobile_apps = Array(MobileApp).from_yaml(Storage.get("mobile_apps.yml").gets_to_end)
    end

    def call
      detected_app = {"name" => "", "version" => ""}
      mobile_apps.each do |app|
        if Regex.new(app.regex, Setting::REGEX_OPTS) =~ @user_agent
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
        end
      end
      detected_app
    end
  end
end
