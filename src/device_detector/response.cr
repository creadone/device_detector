module DeviceDetector
  class Response
    class NotEmplementedException < Exception; end

    alias InputStructure = Array(Hash(String, Hash(String, String)))

    def initialize(@results : InputStructure)
    end

    def raw
      @results
    end

    macro method_missing(m)
      method_name = {{m.name.stringify}}
      raise NotEmplementedException.new("Method #{method_name} not implemented yet.")
    end

    ENTITIES = {
      bot: ["name"],
      browser: ["name", "version"],
      browser_engine: ["name"],
      camera: ["device", "vendor"],
      car_browser: ["model", "vendor"],
      console: ["model", "vendor"],
      feed_reader: ["name", "version"],
      library: ["name", "version"],
      mediaplayer: ["name", "version"],
      mobile_app: ["name", "version"],
      mobile: ["vendor", "type", "model"],
      os: ["name", "version"],
      pim: ["name", "version"],
      portable_media_player: ["model", "vendor"],
      tv: ["model", "vendor"],
      vendorfragment: ["vendor"]
    }

    {% for entity_name, keys in ENTITIES %}
      {% class_name = entity_name.stringify.camelcase %}

      class {{class_name.id}}
        def initialize(@section : Hash(String, String))
        end

        {% for key, index in keys %}
          def {{key.id}}? : Bool
            @section.has_key?({{key}}) && !@section[{{key}}].try &.blank?
          end
          
          def {{key.id}} : String?
            @section[{{key}}]?
          end
        {% end %}
      end

      def {{entity_name.id}}? : Bool
        @results.each do |result|
          if result.has_key?({{entity_name.stringify}})
            return !result.dig?({{entity_name.stringify}}, {{keys.first}}).try &.blank?
          end
        end

        false
      end

      def {{entity_name.id}} : {{class_name.id}}
        @results.each do |result|
          if result.has_key?({{entity_name.stringify}})
            return {{class_name.id}}.new(result[{{entity_name.stringify}}])
          end
        end
        
        {{class_name.id}}.new({} of String => String)
      end

      # Old API support
      {% for key, index in keys %}
        def {{entity_name.id}}_{{key.id}}
          {{entity_name.id}}.{{key.id}}
        end
      {% end %}
    {% end %}

    # Old API support
    def camera_model
      camera.device
    end

    def mobile_device?
      mobile?
    end

    def mobile_device
      mobile
    end

    def mobile_device_vendor
      mobile.vendor
    end

    def mobile_device_type
      mobile.type
    end

    def mobile_device_model
      mobile.model
    end

    # `to.click` related method
    def traffic_type
      if [library?, bot?].any? { |m| m == true }
        "bot"
      else
        "human"
      end
    end
  end
end
