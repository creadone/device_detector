module DeviceDetector::Parser
  struct Television
    include Helper

    getter kind = "tv"
    @@tvs = Hash(String, SingleModelTV | MultiModelTV).from_yaml(Storage.get("televisions.yml"))
    @@overall_regex = nil.as(Regex?)

    TV_HINTS = /TV|HbbTV|SmartTV|NetCast|Web0S|Tizen|BRAVIA|AFT|Roku|CrKey|AppleTV|GoogleTV|Aquos|Viera|DTV/i

    def initialize(user_agent : String)
      @user_agent = user_agent
    end

    struct SingleModelTV
      include YAML::Serializable

      property regex : String
      property model : String
    end

    struct MultiModelTV
      include YAML::Serializable

      property regex : String
      property models : Array(SingleModelTV)
    end

    def tvs
      return @@tvs if @@tvs
      @@tvs = Hash(String, SingleModelTV | MultiModelTV).from_yaml(Storage.get("televisions.yml"))
    end

    def overall_regex
      @@overall_regex ||= regex(tvs.values.map(&.regex).join("|"))
    end

    def call
      detected_tv = {"model" => "", "vendor" => ""}
      return detected_tv unless TV_HINTS =~ @user_agent
      return detected_tv unless overall_regex =~ @user_agent

      tvs.to_a.reverse.to_h.each do |item|
        vendor = item[0]
        device = item[1]

        # --> If device has many models
        if device.is_a?(MultiModelTV)
          if regex(device.regex) =~ @user_agent
            device.models.each do |model|
              if regex(model.regex) =~ @user_agent
                # Fill known keys
                detected_tv.merge!({"vendor" => vendor})
                # If model name contains capture groups
                if capture_groups?(model.model)
                  model_name = fill_groups(model.model, model.regex, @user_agent)
                  detected_tv.merge!({"model" => model_name})
                else
                  detected_tv.merge!({"model" => model.model})
                end
                break
              end
            end
          end
        end

        # --> If device has one model
        if device.is_a?(SingleModelTV)
          if regex(device.regex) =~ @user_agent
            # Fill known keys
            detected_tv.merge!({"vendor" => vendor})
            # If model name contains capture groups
            if capture_groups?(device.model)
              model = fill_groups(device.model, device.regex, @user_agent)
              detected_tv.merge!({"model" => model})
            else
              detected_tv.merge!({"model" => device.model})
            end
          end
        end
        break unless detected_tv["vendor"].blank?
      end
      detected_tv
    end
  end
end
