require "./storage"
require "./parser"
require "./setting"
require "./response"

module DeviceDetector
  struct Detector
    alias Result = Hash(String, Hash(String, String))

    def initialize(@user_agent : String)
    end

    def parse(stack)
      result = [] of Result
      
      stack.each do |parser|
        detector = parser.new(@user_agent)
        result.push({detector.kind => detector.call})
      end

      Response.new(result)
    end

    macro method_missing(m)
      {% if m.name.id.stringify == "call" %}
        stack = Setting::FULL
      {% else %}
        stack = Setting::{{m.name.id.stringify.upcase.id}}
      {% end %}

      parse(stack)
    end
  end
end
