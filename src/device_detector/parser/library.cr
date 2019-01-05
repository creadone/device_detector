module DeviceDetector::Parser
  struct Library
    include Helper

    getter kind = "library"
    @@libraries = Array(Library).from_yaml(Storage.get("library.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Library
      YAML.mapping(
        regex: String,
        name: String,
        version: String
      )
    end

    def libraries
      return @@libraries if @@libraries
      @@libraries = Array(Library).from_yaml(Storage.get("library.yml").gets_to_end)
    end

    def call
      detected_library = {"name" => "", "version" => ""}
      libraries.each do |library|
        if Regex.new(library.regex, Setting::REGEX_OPTS) =~ @user_agent
          detected_library.merge!({"name" => library.name})
          if capture_groups?(library.version)
            version = fill_groups(library.version, library.regex, @user_agent)
            detected_library.merge!({"version" => version})
          else
            detected_library.merge!({"version" => library.version})
          end
        end
      end
      detected_library
    end
  end
end
