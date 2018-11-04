module DeviceDetector
  class VendorFragmentStore
    include Helper

    getter kind = "vendorfragment"

    def initialize(user_agent : String)
      @fragments = Hash(String, Array(String)).from_yaml(Storage.get("vendorfragments.yml").gets_to_end)
      @user_agent = user_agent
    end

    def call
      detected_vendor = {"vendor" => ""}
      @fragments.each do |fragment|
        vendor = fragment[0]
        regexes = fragment[1]
        regexes.each do |regex|
          if Regex.new(regex, Settings::REGEX_OPTS) =~ @user_agent
            detected_vendor.merge!({"vendor" => vendor})
          end
        end
      end
      detected_vendor
    end
  end
end
