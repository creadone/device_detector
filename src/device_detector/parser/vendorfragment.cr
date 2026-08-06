module DeviceDetector::Parser
  struct VendorFragment
    include Helper

    getter kind = "vendorfragment"
    @@fragments = Hash(String, Array(String)).from_yaml(Storage.get("vendorfragments.yml"))

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    def fragments : Hash(String, Array(String))
      @@fragments
    end

    # Returns the regular-expression sources used by this parser.
    def self.regex_patterns : Array(String)
      @@fragments.values.flatten
    end

    # Compiles all vendor-fragment rules into the shared immutable registry.
    def self.prepare : Nil
      Helper.prepare_regexes(regex_patterns)
    end

    def call
      detected_vendor = {"vendor" => ""}
      fragments.each do |fragment|
        vendor = fragment[0]
        regexes = fragment[1]
        regexes.each do |regex|
          if self.regex(regex) =~ @user_agent
            detected_vendor.merge!({"vendor" => vendor})
            break
          end
        end
        break unless detected_vendor["vendor"].blank?
      end
      detected_vendor
    end
  end
end
