module DeviceDetector
  module Helper
    extend self

    # Detect capture group
    def capture_groups?(str : String)
      !str.scan(/(\$\d)/).empty?
    end

    # Fill capture groups
    def fill_groups(str : String, regex : String, user_agent : String)
      keys = str.scan(/(\$\d)/)
      values = user_agent.match(Regex.new(regex, DeviceDetector::Settings::REGEX_OPTS))
      new_str = str
      keys.each do |key|
        index = key[1]?.not_nil!.delete("$").to_i
        place = key[1]?.not_nil!
        filler = values.try &.[index]?.to_s
        new_str = new_str.gsub(place, filler)
      end
      return new_str
    end
  end
end
