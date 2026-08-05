require "./spec_helper"
require "fiber/execution_context"
require "wait_group"

describe "Helper" do
  it "should detect capture group" do
    DeviceDetector::Helper.capture_groups?("$1").should be_true
  end

  it "should fill capture groups" do
    user_agent = "Browser/123.45"
    DeviceDetector::Helper.fill_groups("version $1", "Browser/(\\d+\\.\\d+)", user_agent).should eq("version 123.45")
  end

  it "matches prepared regular expressions across parallel workers" do
    pattern = "PreparedBrowser/(\\d+\\.\\d+)"
    DeviceDetector::Helper.prepare_regexes([pattern])
    context = Fiber::ExecutionContext::Parallel.new("prepared-regex-spec", 4)
    workers = WaitGroup.new(100)
    failures = Atomic(Int32).new(0)

    100.times do
      context.spawn do
        100.times do
          matched = DeviceDetector::Helper.regex(pattern).match("PreparedBrowser/123.45")
          failures.add(1, :relaxed) unless matched.try(&.[1]?) == "123.45"
        end
      ensure
        workers.done
      end
    end

    workers.wait
    failures.get(:relaxed).should eq(0)
  end

  it "uses thread-safe fallback caches for unprepared regular expressions" do
    context = Fiber::ExecutionContext::Parallel.new("fallback-regex-spec", 4)
    workers = WaitGroup.new(100)
    failures = Atomic(Int32).new(0)

    100.times do |worker|
      context.spawn do
        100.times do |iteration|
          suffix = (worker + iteration) % 17
          pattern = "Fallback#{suffix}/(\\d+)"
          failures.add(1, :relaxed) unless DeviceDetector::Helper.regex(pattern) =~ "Fallback#{suffix}/42"
        end
      ensure
        workers.done
      end
    end

    workers.wait
    failures.get(:relaxed).should eq(0)
  end
end
