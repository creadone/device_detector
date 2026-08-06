module DeviceDetector::Parser
  struct FeedReader
    include Helper

    getter kind = "feed_reader"
    @@readers = Array(Reader).from_yaml(Storage.get("feed_readers.yml"))
    @@overall_pattern : String = @@readers.map(&.regex).join("|")

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Reader
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def readers : Array(Reader)
      @@readers
    end

    def overall_regex : Regex
      regex(@@overall_pattern)
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      patterns = @@readers.map(&.regex)
      patterns << @@overall_pattern
    end

    # Compiles all feed-reader rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_reader = {"name" => "", "version" => ""}
      return detected_reader unless overall_regex =~ @user_agent

      readers.each do |reader|
        if regex(reader.regex) =~ @user_agent
          detected_reader.merge!({"name" => reader.name})
          if capture_groups?(reader.version.to_s)
            version = fill_groups(reader.version.to_s, reader.regex, @user_agent)
            detected_reader.merge!({"version" => version.to_s})
          else
            detected_reader.merge!({"version" => reader.version.to_s})
          end
          break
        end
      end
      detected_reader
    end
  end
end
