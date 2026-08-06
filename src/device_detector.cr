require "./device_detector/*"

module DeviceDetector
  # Precompiles the regular expressions used by *parsers* and publishes them
  # as one immutable snapshot shared by all execution-context workers.
  def self.prepare(parsers : Enumerable(Setting::ParserClass) = Setting::FULL) : Nil
    patterns = [] of String
    parsers.each { |parser| patterns.concat(parser.regex_patterns) }
    Helper.prepare_regexes(patterns)
  end

  def new
  end
end
