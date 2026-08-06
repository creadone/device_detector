require "./spec_helper"
require "../src/device_detector/cli/command"
require "json"

CLI_PIXEL_USER_AGENT = "Mozilla/5.0 (Linux; Android 13; Pixel 7 Build/TQ3A) " \
                       "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 " \
                       "Mobile Safari/537.36"
CLI_BOT_USER_AGENT = "Mozilla/5.0 (compatible; Googlebot/2.1; +https://www.google.com/bot.html)"

private def run_cli(arguments : Array(String), input_text = "")
  input = IO::Memory.new(input_text)
  output = IO::Memory.new
  error = IO::Memory.new
  command = DeviceDetector::CLI::Command.new(input: input, output: output, error: error)
  status = command.run(arguments)

  {status: status, output: output.to_s, error: error.to_s}
end

private def json_lines(output : String) : Array(JSON::Any)
  output.lines.map { |line| JSON.parse(line) }
end

describe DeviceDetector::CLI::Command do
  it "parses one User-Agent passed as an argument" do
    result = run_cli([CLI_PIXEL_USER_AGENT])

    result[:status].should eq(0)
    result[:error].should be_empty

    records = json_lines(result[:output])
    records.size.should eq(1)
    record = records.first
    record["user_agent"].as_s.should eq(CLI_PIXEL_USER_AGENT)
    record["traffic_type"].as_s.should eq("human")
    record["browser"]["name"].as_s.should eq("Chrome Mobile")
    record["browser_engine"]["name"].as_s.should eq("Blink")
    record["os"]["name"].as_s.should eq("Android")
    record["mobile"]["vendor"].as_s.should eq("Google")
    record["mobile"]["model"].as_s.should eq("Pixel 7")
    record.as_h.has_key?("bot").should be_false
  end

  it "parses newline-delimited stdin in parallel and preserves input order" do
    input = "\n#{CLI_BOT_USER_AGENT}\r\n#{CLI_PIXEL_USER_AGENT}\n"
    result = run_cli(["--workers", "2"], input)

    result[:status].should eq(0)
    result[:error].should be_empty

    records = json_lines(result[:output])
    records.map(&.["user_agent"].as_s).should eq([CLI_BOT_USER_AGENT, CLI_PIXEL_USER_AGENT])
    records[0]["traffic_type"].as_s.should eq("bot")
    records[0]["bot"]["name"].as_s.should eq("Googlebot")
    records[1]["traffic_type"].as_s.should eq("human")
    records[1]["mobile"]["model"].as_s.should eq("Pixel 7")
  end

  it "splits newlines inside positional arguments" do
    result = run_cli(["--workers=2", "#{CLI_BOT_USER_AGENT}\n#{CLI_PIXEL_USER_AGENT}"])

    result[:status].should eq(0)
    json_lines(result[:output]).map(&.["user_agent"].as_s).should eq([
      CLI_BOT_USER_AGENT,
      CLI_PIXEL_USER_AGENT,
    ])
  end

  it "reports invalid worker counts" do
    result = run_cli(["--workers", "0", CLI_PIXEL_USER_AGENT])

    result[:status].should eq(2)
    result[:output].should be_empty
    result[:error].should contain("--workers must be a positive integer")
  end

  it "reports empty input" do
    result = run_cli([] of String)

    result[:status].should eq(1)
    result[:output].should be_empty
    result[:error].should contain("No User-Agent input")
  end

  it "prints help without reading input" do
    result = run_cli(["--help"])

    result[:status].should eq(0)
    result[:output].should contain("Usage: device-detector")
    result[:output].should contain("--workers")
    result[:error].should be_empty
  end

  it "prints the shard version" do
    result = run_cli(["--version"])

    result[:status].should eq(0)
    result[:output].strip.should eq("device-detector #{DeviceDetector::VERSION}")
    result[:error].should be_empty
  end
end
