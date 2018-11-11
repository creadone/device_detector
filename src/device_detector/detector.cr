require "./storage"
require "./parsers"
require "./settings"
require "./response"

module DeviceDetector
  class Detector
    alias Result = Hash(String, Hash(String, String))

    def initialize(user_agent : String)
      @user_agent = user_agent
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
        stack = Settings::FULL
      {% else %}
        stack = Settings::{{ m.name.id.stringify.upcase.id }}
      {% end %}
      parse(stack)
    end
  end
end
