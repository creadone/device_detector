module DeviceDetector::Parser
  struct VendorFragment
    include Helper

    getter kind = "vendorfragment"
    @@fragments = Hash(String, Array(String)).from_yaml(Storage.get("vendorfragments.yml").gets_to_end)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    def fragments
      return @@fragments if @@fragments
      @@fragments = Hash(String, Array(String)).from_yaml(Storage.get("vendorfragments.yml").gets_to_end)
    end

    def call
      detected_vendor = {"vendor" => ""}
      fragments.each do |fragment|
        vendor = fragment[0]
        regexes = fragment[1]
        regexes.each do |regex|
          if Regex.new(regex, Setting::REGEX_OPTS) =~ @user_agent
            detected_vendor.merge!({"vendor" => vendor})
          end
        end
      end
      detected_vendor
    end
  end
end
