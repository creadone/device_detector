module DeviceDetector::Parser
  struct FeedReader
    include Helper

    getter kind = "feed_reader"
    @@readers = Array(Reader).from_yaml(Storage.get("feed_readers.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct Reader
      YAML.mapping(
        regex: String,
        name: String,
        version: {type: String?, presence: true}
      )
    end

    def readers
      return @@readers if @@readers
      @@readers = Array(Reader).from_yaml(Storage.get("feed_readers.yml").gets_to_end)
    end

    def call
      detected_reader = {"name" => "", "version" => ""}
      readers.each do |reader|
        if Regex.new(reader.regex, Setting::REGEX_OPTS) =~ @user_agent
          detected_reader.merge!({"name" => reader.name})
          if capture_groups?(reader.version.to_s)
            version = fill_groups(reader.version.to_s, reader.regex, @user_agent)
            detected_reader.merge!({"version" => version.to_s})
          else
            detected_reader.merge!({"version" => reader.version.to_s})
          end
        end
      end
      detected_reader
    end
  end
end
