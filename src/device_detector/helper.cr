module DeviceDetector
  module Helper
    extend self

    @@regexes = {} of String => Regex
    @@regexes_with_options = {} of Tuple(String, Regex::Options) => Regex

    CAPTURE_GROUP_REGEX = /(\$\d)/
    HUMAN_BROWSER_HINTS = /Mozilla|AppleWebKit|Chrome|Safari|Firefox|Edge|Edg|MSIE|Trident/i
    DESKTOP_HINTS       = /Windows NT|Macintosh|X11|CrOS/i

    def regex(pattern : String)
      @@regexes[pattern] ||= Regex.new(pattern, Setting::REGEX_OPTS)
    end

    def regex(pattern : String, options : Regex::Options)
      key = {pattern, options}
      @@regexes_with_options[key] ||= Regex.new(pattern, options)
    end

    def human_browser?(user_agent : String)
      !!(HUMAN_BROWSER_HINTS =~ user_agent)
    end

    def desktop?(user_agent : String)
      !!(DESKTOP_HINTS =~ user_agent)
    end

    # Detect capture group
    def capture_groups?(str : String)
      !(CAPTURE_GROUP_REGEX =~ str).nil?
    end

    # Fill capture groups
    def fill_groups(str : String, regex : String, user_agent : String)
      keys = str.scan(CAPTURE_GROUP_REGEX)
      values = user_agent.match(self.regex(regex))
      new_str = str

      keys.each do |key|
        place = key[1]
        index = place.delete("$").to_i
        filler = values.try(&.[index]?.to_s) || ""
        new_str = new_str.gsub(place, filler)
      end

      new_str
    end
  end
end
