require "set"
require "sync"

module DeviceDetector
  module Helper
    extend self

    private class PreparedRegexes
      alias OptionsKey = Tuple(String, Regex::Options)

      def initialize(
        @defaults = {} of String => Regex,
        @with_options = {} of OptionsKey => Regex,
      )
      end

      def default?(pattern : String) : Regex?
        @defaults[pattern]?
      end

      def with_options?(pattern : String, options : Regex::Options) : Regex?
        @with_options[{pattern, options}]?
      end

      def with(patterns : Enumerable(String), options : Regex::Options) : self
        if options == Setting::REGEX_OPTS
          missing = Set(String).new
          patterns.each { |pattern| missing << pattern unless @defaults.has_key?(pattern) }
          return self if missing.empty?

          defaults = @defaults.dup
          missing.each { |pattern| defaults[pattern] = Regex.new(pattern, options) }
          self.class.new(defaults, @with_options)
        else
          missing = Set(OptionsKey).new
          patterns.each do |pattern|
            key = {pattern, options}
            missing << key unless @with_options.has_key?(key)
          end
          return self if missing.empty?

          with_options = @with_options.dup
          missing.each do |key|
            with_options[key] = Regex.new(key[0], options)
          end
          self.class.new(@defaults, with_options)
        end
      end
    end

    @@prepared_regexes = Atomic(PreparedRegexes?).new(nil)
    @@prepare_lock = Sync::Mutex.new

    # `thread_local` declarations generate accessors; they are not assignments.
    thread_local(local_regexes : Hash(String, Regex)) { {} of String => Regex }              # ameba:disable Lint/UselessAssign
    thread_local(local_regexes_with_options : Hash(Tuple(String, Regex::Options), Regex)) do # ameba:disable Lint/UselessAssign
      {} of Tuple(String, Regex::Options) => Regex
    end

    CAPTURE_GROUP_REGEX = /(\$\d)/
    TOKEN_REGEX         = /[a-z0-9][a-z0-9._+-]{2,}/i
    HUMAN_BROWSER_HINTS = /Mozilla|AppleWebKit|Chrome|Safari|Firefox|Edge|Edg|MSIE|Trident/i
    DESKTOP_HINTS       = /Windows NT|Macintosh|X11|CrOS/i

    def prepare_regexes(patterns : Enumerable(String), options = Setting::REGEX_OPTS) : Nil
      @@prepare_lock.synchronize do
        current = @@prepared_regexes.get(:acquire) || PreparedRegexes.new
        @@prepared_regexes.set(current.with(patterns, options), :release)
      end
    end

    def regex(pattern : String) : Regex
      if prepared = @@prepared_regexes.get(:acquire)
        if compiled = prepared.default?(pattern)
          return compiled
        end
      end

      regexes = Helper.local_regexes
      regexes[pattern] ||= Regex.new(pattern, Setting::REGEX_OPTS)
    end

    def regex(pattern : String, options : Regex::Options) : Regex
      if prepared = @@prepared_regexes.get(:acquire)
        if compiled = prepared.with_options?(pattern, options)
          return compiled
        end
      end

      key = {pattern, options}
      regexes = Helper.local_regexes_with_options
      regexes[key] ||= Regex.new(pattern, options)
    end

    def human_browser?(user_agent : String)
      !!(HUMAN_BROWSER_HINTS =~ user_agent)
    end

    def desktop?(user_agent : String)
      !!(DESKTOP_HINTS =~ user_agent)
    end

    def token_candidates(index : Hash(String, Array(Int32)), user_agent : String, reverse = false)
      candidates = [] of Int32
      seen = Set(Int32).new

      user_agent.downcase.scan(TOKEN_REGEX) do |match|
        token = match[0]
        next unless indexes = index[token]?

        indexes.each do |rule_index|
          next if seen.includes?(rule_index)

          seen << rule_index
          candidates << rule_index
        end
      end

      candidates.sort!
      candidates.reverse! if reverse
      candidates
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
