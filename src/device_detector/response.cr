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

    macro def_entity(name, keys)
      {% for key, index in keys %}
        {% if index == 0 %}
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

    def_entity "bot", ["name"]
    def_entity "browser", ["name", "version"]
    def_entity "browser_engine", ["name"]
    def_entity "camera", ["device", "vendor"]
    def_entity "car_browser", ["model", "vendor"]
    def_entity "console", ["model", "vendor"]
    def_entity "feed_reader", ["name", "version"]
    def_entity "library", ["name", "version"]
    def_entity "mediaplayer", ["name", "version"]
    def_entity "mobile_app", ["name", "version"]
    def_entity "mobile", ["vendor", "type", "model"]
    def_entity "oss", ["name", "version"]
    def_entity "pim", ["name", "version"]
    def_entity "portable_media_player", ["model", "vendor"]
    def_entity "tv", ["model", "vendor"]
    def_entity "vendorfragment", ["vendor"]

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
