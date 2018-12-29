module DeviceDetector
  struct Response
    class NotEmplementedException < Exception; end

    alias InputStructure = Array(Hash(String, Hash(String, String)))

    def initialize(results : InputStructure)
      @results = results
    end

    def raw
      @results
    end

    macro method_missing(m)
      method_name = {{ m.name.stringify }}
      raise NotEmplementedException.new("Method #{method_name} not implemented yet.")
    end

    macro entity(name, keys)
      {% for key in keys %}
        {% if key == keys.first %}
          def {{name.id}}?
            @results.each do |result|
              if result.has_key?({{name}})
                return !result.dig?({{name}}, {{key}}).try &.blank?
              end
            end
        
            false
          end
        {% end %}
        
        def {{name.id}}_{{key.id}}
          @results.each do |result|
            if result.has_key?({{name}})
              return result.dig?({{name}}, {{key}})
            end
          end
        end
      {% end %}
    end

    entity "bot", ["name"]
    entity "browser", ["name", "version"]
    entity "browser_engine", ["name"]
    entity "camera", ["device", "vendor"]
    entity "car_browser", ["model", "vendor"]
    entity "console", ["model", "vendor"]
    entity "feed_reader", ["name", "version"]
    entity "library", ["name", "version"]
    entity "mediaplayer", ["name", "version"]
    entity "mobile_app", ["name", "version"]
    entity "mobile", ["vendor", "type", "model"]
    entity "oss", ["name", "version"]
    entity "pim", ["name", "version"]
    entity "portable_media_player", ["model", "vendor"]
    entity "tv", ["model", "vendor"]
    entity "vendorfragment", ["vendor"]

    # --> Old API support

    def camera_model
      camera_device
    end

    def mobile_device?
      mobile?
    end

    def mobile_device?
      mobile?
    end

    def mobile_device_vendor
      mobile_vendor
    end

    def mobile_device_type
      mobile_type
    end

    def mobile_device_model
      mobile_model
    end

    def os?
      oss?
    end

    def os_name
      oss_name
    end

    def os_version
      oss_version
    end

    # --> to.click related methods

    def traffic_type
      if [library?, bot?].any? { |m| m == true }
        return "bot"
      else
        return "human"
      end
    end
  end
end
