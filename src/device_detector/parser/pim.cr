module DeviceDetector::Parser
  struct PIM
    include Helper

    getter kind = "pim"
    @@pims = Array(PIM).from_yaml(Storage.get("pim.yml"))
    @@overall_regex = nil.as(Regex?)

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct PIM
      include YAML::Serializable

      property regex : String
      property name : String
      property version : String?
    end

    def pims
      return @@pims if @@pims
      @@pims = Array(PIM).from_yaml(Storage.get("pim.yml"))
    end

    def overall_regex
      @@overall_regex ||= regex(pims.map(&.regex).join("|"))
    end

    def call
      detected_pim = {"name" => "", "version" => ""}
      return detected_pim unless overall_regex =~ @user_agent

      pims.each do |pim|
        if regex(pim.regex) =~ @user_agent
          detected_pim.merge!({"name" => pim.name})
          if capture_groups?(pim.version.to_s)
            version = fill_groups(pim.version.to_s, pim.regex, @user_agent)
            detected_pim.merge!({"version" => version})
          else
            detected_pim.merge!({"version" => pim.version.to_s})
          end
          break
        end
      end
      detected_pim
    end
  end
end
