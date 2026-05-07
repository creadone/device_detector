require "../src/device_detector"
require "benchmark"

COUNT                      =  1000
MIN_USER_AGENTS_PER_SECOND = 150.0
user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"

def measure(label, count, user_agent, &)
  elapsed = Benchmark.realtime do
    count.times do
      yield DeviceDetector::Detector.new(user_agent)
    end
  end

  seconds = elapsed.total_seconds
  rate = count / seconds
  printf "%-5s %8.2f user-agent/sec (%0.6fs)\n", label, rate, seconds
  rate
end

full_rate = measure("full:", COUNT, user_agent) do |detector|
  detector.call.raw
end

measure("lite:", COUNT, user_agent) do |detector|
  detector.lite.raw
end

if full_rate < MIN_USER_AGENTS_PER_SECOND
  abort "Expected full parser speed to be at least #{MIN_USER_AGENTS_PER_SECOND} user-agent/sec, got #{full_rate.round(2)}."
end
