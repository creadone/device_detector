module DeviceDetector
  class LibraryStore
    include Helper

    getter kind = "library"

    def initialize(user_agent : String)
      @libraries = Array(Library).from_yaml(Storage.get("libraries.yml").gets_to_end)
      @user_agent = user_agent
    end

    class Library
      YAML.mapping(
        regex: String,
        name: String,
        version: String
      )
    end

    def call
      detected_library = {"name" => "", "version" => ""}
      @libraries.each do |library|
        if Regex.new(library.regex) =~ @user_agent
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
