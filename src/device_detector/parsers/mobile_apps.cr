module DeviceDetector
  class MobileAppStore
    include Helper

    getter kind = "mobile_app"

    def initialize(user_agent : String)
      @mobile_apps = Array(MobileApp).from_yaml(Storage.get("mobile_apps.yml").gets_to_end)
      @user_agent = user_agent
    end

    class MobileApp
      YAML.mapping(
        regex: String,
        name: String,
        version: String?
      )
    end

    def call
      detected_app = {"name" => "", "version" => ""}
      @mobile_apps.each do |app|
        if Regex.new(app.regex, Settings::REGEX_OPTS) =~ @user_agent
          # -> If name contains capture groups
          if capture_groups?(app.name)
            name = fill_groups(app.name, app.regex, @user_agent)
            detected_app.merge!({"name" => name})
          else
            detected_app.merge!({"name" => app.name})
          end
          # -> If name contains capture groups
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
