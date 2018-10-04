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

    def call
      result = [] of Result
      Settings::PARSERS.each do |parser|
        detector = parser.new(@user_agent)
        result.push({detector.kind => detector.call})
      end
      Response.new(result)
    end
  end
end
