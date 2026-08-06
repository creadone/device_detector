require "./spec_helper"
require "fiber/execution_context"
require "wait_group"

EXECUTION_CONTEXT_USER_AGENTS = [
  "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0",
  "Mozilla/5.0 (Linux; U; Android 2.3.3; ja-jp; COOLPIX S800c Build/CP01_WW) AppleWebKit/533.1 Mobile Safari/533.1",
  "Mozilla/5.0 (X11; u; Linux; C) AppleWebKit/533.3 QtCarBrowser Safari/533.3",
  "Mozilla/5.0 (PLAYSTATION 3 4.46) AppleWebKit/531.22.8",
  "FeeddlerRSS/2.4 CFNetwork/548.1.4 Darwin/11.0.0",
  "curl/7.21.0 (i386-redhat-linux-gnu) libcurl/7.21.0",
  "iTunes/10.2.1 (Macintosh; Intel Mac OS X 10.7) AppleWebKit/534.20.8",
  "WhatsApp/2.6.4 iPhone_OS/4.3.3 Device/iPhone_4",
  "Mozilla/5.0 (Linux; Android 10; ELS-NX9 Build/HUAWEIELS-NX9) AppleWebKit/537.36 Mobile HuaweiBrowser/13.0",
  "Mozilla/5.0 (Linux; Android 14; FCP-AN10 Build/HONORFCP-AN10) AppleWebKit/537.36 Mobile",
  "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.12; Microsoft ZuneHD 4.3)",
  "Opera/9.80 (Linux armv7l; HbbTV/1.2.1 (; Hisense; SmartTV_2015; HE65M7000UWTSG; )) Presto/2.12.407",
  "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
]

private def full_results : Hash(String, DeviceDetector::Response::InputStructure)
  EXECUTION_CONTEXT_USER_AGENTS.to_h do |user_agent|
    {user_agent, DeviceDetector::Detector.new(user_agent).call.raw}
  end
end

private def parallel_full_failures(
  expected : Hash(String, DeviceDetector::Response::InputStructure),
  tasks : Int32,
) : Int32
  context = Fiber::ExecutionContext::Parallel.new("device-detector-full-spec", 4)
  workers = WaitGroup.new(tasks)
  failures = Atomic(Int32).new(0)

  tasks.times do
    context.spawn do
      expected.each do |user_agent, result|
        actual = DeviceDetector::Detector.new(user_agent).call.raw
        failures.add(1, :relaxed) unless actual == result
      end
    rescue
      failures.add(1, :relaxed)
    ensure
      workers.done
    end
  end

  workers.wait
  failures.get(:relaxed)
end

describe "Execution context safety" do
  it "keeps the unprepared full parser deterministic across parallel workers" do
    parallel_full_failures(full_results, 24).should eq(0)
  end

  it "publishes full preparation atomically while parsing continues" do
    expected = full_results
    parse_tasks = 24
    prepare_tasks = 4
    context = Fiber::ExecutionContext::Parallel.new("device-detector-prepare-spec", 4)
    workers = WaitGroup.new(parse_tasks + prepare_tasks)
    failures = Atomic(Int32).new(0)

    parse_tasks.times do
      context.spawn do
        expected.each do |user_agent, result|
          actual = DeviceDetector::Detector.new(user_agent).call.raw
          failures.add(1, :relaxed) unless actual == result
        end
      rescue
        failures.add(1, :relaxed)
      ensure
        workers.done
      end
    end

    prepare_tasks.times do
      context.spawn do
        DeviceDetector.prepare
      rescue
        failures.add(1, :relaxed)
      ensure
        workers.done
      end
    end

    workers.wait
    failures.get(:relaxed).should eq(0)
  end

  it "exposes preparation for every full and lite parser" do
    DeviceDetector::Setting::FULL.each do |parser|
      parser.regex_patterns.should_not be_empty
    end

    DeviceDetector.prepare(DeviceDetector::Setting::LITE)
  end
end
