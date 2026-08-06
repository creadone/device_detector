module DeviceDetector::Parser
  struct Library
    include Helper

    getter kind = "library"
    @@libraries = Array(Library).from_yaml(Storage.get("libraries.yml"))

    LIBRARY_HINTS = /curl|libcurl|wget|python|java|okhttp|httpclient|http.rb|Go-http-client|axios|node|ruby|perl|php|postman/i

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Library
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def libraries : Array(Library)
      @@libraries
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      @@libraries.map(&.regex)
    end

    # Compiles all library-client rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_library = {"name" => "", "version" => ""}
      return detected_library if human_browser?(@user_agent) && !(LIBRARY_HINTS =~ @user_agent)

      libraries.each do |library|
        if regex(library.regex) =~ @user_agent
          detected_library.merge!({"name" => library.name})
          if capture_groups?(library.version.to_s)
            version = fill_groups(library.version.to_s, library.regex, @user_agent)
            detected_library.merge!({"version" => version})
          else
            detected_library.merge!({"version" => library.version.to_s})
          end
          break
        end
      end
      detected_library
    end
  end
end
