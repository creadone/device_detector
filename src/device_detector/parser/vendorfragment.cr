module DeviceDetector::Parser
  struct VendorFragment
    include Helper

    getter kind = "vendorfragment"
    @@fragments = Hash(String, Array(String)).from_yaml(Storage.get("vendorfragments.yml"))

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    def fragments
      return @@fragments if @@fragments
      @@fragments = Hash(String, Array(String)).from_yaml(Storage.get("vendorfragments.yml"))
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
