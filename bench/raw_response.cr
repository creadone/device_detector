require "../src/DeviceDetector"
require "benchmark"

COUNT = 1000

user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"

puts Benchmark.measure {
  COUNT.times do
    detector = DeviceDetector::Detector.new(user_agent)
    detector.call
  end
}
