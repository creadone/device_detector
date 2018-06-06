module DeviceDetector
  class FeedReaderStore
    include Helper

    getter kind = "feed_reader"

    def initialize(user_agent : String)
      @readers = Array(Reader).from_yaml(Storage.get("feed_readers.yml").gets_to_end)
      @user_agent = user_agent
    end

    class Reader
      YAML.mapping(
        regex: String,
        name: String,
        version: {type: String?, presence: true}
      )
    end

    def call
      detected_reader = {} of String => String
      @readers.each do |reader|
        if Regex.new(reader.regex, Regex::Options::IGNORE_CASE) =~ @user_agent
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
