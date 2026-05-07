require "../src/device_detector"
require "benchmark"
require "set"

COUNT                      =   10_000
MIN_USER_AGENTS_PER_SECOND =    150.0
RANDOM_SEED                = 20260507

WINDOWS_VERSIONS    = ["10.0", "6.3", "6.2", "6.1", "6.0"]
MACOS_VERSIONS      = ["10_15_7", "11_7_10", "12_6_9", "13_6_1", "14_0"]
LINUX_ARCHES        = ["x86_64", "i686", "aarch64", "armv7l"]
ANDROID_VERSIONS    = ["8.1.0", "9", "10", "11", "12", "13", "14"]
ANDROID_MODELS      = ["SM-G991B", "Pixel 7", "M2101K9G", "BV6000", "CPH2207", "Redmi Note 11", "Nokia G20", "Moto G Power"]
IOS_DEVICES         = ["iPhone", "iPad"]
IOS_VERSIONS        = ["14_8", "15_7", "16_6", "17_0", "17_1"]
BOT_NAMES           = ["Googlebot", "Bingbot", "YandexBot", "DuckDuckBot", "AhrefsBot", "SemrushBot", "MJ12bot", "DotBot"]
APP_NAMES           = ["WhatsApp", "Telegram", "Instagram", "Facebook", "TikTok", "Spotify", "Slack", "Discord"]
LIBRARY_NAMES       = ["curl", "Wget", "python-requests", "Go-http-client", "okhttp", "PostmanRuntime", "libwww-perl", "Java"]
TV_VENDORS          = ["Hisense", "Samsung", "LG", "Sony", "Philips", "TCL", "Panasonic", "Sharp"]
USER_AGENT_BUILDERS = [
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (Windows NT #{sample(random, WINDOWS_VERSIONS)}; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/#{browser_version(random, sequence)} Safari/537.36"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (Macintosh; Intel Mac OS X #{sample(random, MACOS_VERSIONS)}) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/#{random.rand(13..17)}.#{random.rand(0..6)} Safari/605.1.15 Build/#{sequence}"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (X11; Linux #{sample(random, LINUX_ARCHES)}; rv:#{random.rand(80..125)}.#{sequence}) Gecko/20100101 Firefox/#{random.rand(80..125)}.#{sequence}"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (Linux; Android #{sample(random, ANDROID_VERSIONS)}; #{sample(random, ANDROID_MODELS)} Build/DD#{sequence}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/#{browser_version(random, sequence)} Mobile Safari/537.36"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (#{sample(random, IOS_DEVICES)}; CPU OS #{sample(random, IOS_VERSIONS)} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/#{random.rand(13..17)}.#{random.rand(0..6)} Mobile/#{sequence} Safari/604.1"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (Linux; Android #{sample(random, ANDROID_VERSIONS)}; #{sample(random, ANDROID_MODELS)} Build/DD#{sequence}) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/#{browser_version(random, sequence)} YaBrowser/#{app_version(random, sequence)} Mobile Safari/537.36"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (compatible; #{sample(random, BOT_NAMES)}/#{app_version(random, sequence)}; +https://example.com/bot/#{sequence})"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "#{sample(random, LIBRARY_NAMES)}/#{app_version(random, sequence)}"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "#{sample(random, APP_NAMES)}/#{app_version(random, sequence)} Android/#{sample(random, ANDROID_VERSIONS)} Device/#{sample(random, ANDROID_MODELS).gsub(' ', '_')}"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/5.0 (PLAYSTATION #{random.rand(3..5)} #{random.rand(1..9)}.#{sequence % 100}) AppleWebKit/537.36 (KHTML, like Gecko)"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Opera/9.80 (Linux armv7l; HbbTV/1.2.1 (; #{sample(random, TV_VENDORS)}; SmartTV_#{random.rand(2015..2024)}; V#{app_version(random, sequence)}; TV#{sequence}; )) Presto/2.12.407 Version/12.51"
  },
  ->(random : Random::PCG32, sequence : Int32) {
    "Mozilla/4.0 (compatible; MSIE #{random.rand(6..11)}.0; Windows NT #{sample(random, WINDOWS_VERSIONS)}; Trident/#{random.rand(4..7)}.0; Microsoft Outlook #{random.rand(12..16)}.#{sequence}; ms-office; MSOffice #{random.rand(12..16)})"
  },
]

def sample(random, values)
  values[random.rand(values.size)]
end

def browser_version(random, sequence)
  "#{random.rand(80..125)}.#{sequence}.#{random.rand(0..999)}.#{random.rand(0..999)}"
end

def app_version(random, sequence)
  "#{random.rand(1..25)}.#{random.rand(0..99)}.#{sequence}"
end

def build_user_agent(random, sequence)
  USER_AGENT_BUILDERS.sample(random).call(random, sequence)
end

def build_workload(count, seed)
  random = Random.new(seed)
  seen = Set(String).new
  user_agents = [] of String

  until user_agents.size == count
    user_agent = build_user_agent(random, user_agents.size)
    next if seen.includes?(user_agent)

    seen << user_agent
    user_agents << user_agent
  end

  user_agents
end

def measure(label, user_agents, &)
  elapsed = Benchmark.realtime do
    user_agents.each do |user_agent|
      yield DeviceDetector::Detector.new(user_agent)
    end
  end

  count = user_agents.size
  seconds = elapsed.total_seconds
  rate = count / seconds
  printf "%-5s %8.2f user-agent/sec (%0.6fs)\n", label, rate, seconds
  rate
end

workload = build_workload(COUNT, RANDOM_SEED)
abort "Expected #{COUNT} unique user-agents, got #{workload.size}." unless workload.size == COUNT
puts "workload: #{workload.size} unique user-agents"

full_rate = measure("full:", workload) do |detector|
  detector.call.raw
end

measure("lite:", workload) do |detector|
  detector.lite.raw
end

if full_rate < MIN_USER_AGENTS_PER_SECOND
  abort "Expected full parser speed to be at least #{MIN_USER_AGENTS_PER_SECOND} user-agent/sec, got #{full_rate.round(2)}."
end
