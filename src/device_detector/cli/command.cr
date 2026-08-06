require "../../device_detector"
require "fiber/execution_context"
require "json"
require "option_parser"
require "wait_group"

module DeviceDetector::CLI
  # Implements the `device-detector` command without terminating the process,
  # allowing applications and specs to provide their own IO streams.
  class Command
    DEFAULT_WORKERS = System.cpu_count

    private record WorkItem, index : Int32, user_agent : String
    private record ParseResult, index : Int32, json : String, error : String?

    def initialize(
      @input : IO = STDIN,
      @output : IO = STDOUT,
      @error : IO = STDERR,
    )
    end

    # Parses command-line *arguments* and returns a process exit status.
    def run(arguments : Array(String)) : Int32
      requested_workers = DEFAULT_WORKERS
      positional = [] of String
      show_help = false
      show_version = false

      parser = OptionParser.new do |options|
        options.banner = <<-TEXT
          Usage: device-detector [options] [USER_AGENT ...]
                 device-detector [options] < user-agents.txt
          TEXT
        options.on("-w N", "--workers=N", "Parse with up to N workers (default: #{DEFAULT_WORKERS})") do |value|
          workers = value.to_i?
          raise ArgumentError.new("--workers must be a positive integer") unless workers && workers > 0

          requested_workers = workers
        end
        options.on("-v", "--version", "Print version") { show_version = true }
        options.on("-h", "--help", "Show this help") { show_help = true }
        options.unknown_args do |before_dash, after_dash|
          positional.concat(before_dash)
          positional.concat(after_dash)
        end
      end

      begin
        parser.parse(arguments.dup)
      rescue ex : OptionParser::Exception | ArgumentError
        @error.puts "Error: #{ex.message}"
        @error.puts parser
        return 2
      end

      if show_help
        @output.puts parser
        return 0
      end

      if show_version
        @output.puts "device-detector #{DeviceDetector::VERSION}"
        return 0
      end

      user_agents = read_user_agents(positional)
      if user_agents.empty?
        @error.puts "Error: No User-Agent input. Pass an argument or newline-delimited data on stdin."
        return 1
      end

      worker_count = Math.min(requested_workers, user_agents.size)
      success = if worker_count == 1
                  parse_sequential(user_agents)
                else
                  DeviceDetector.prepare
                  parse_parallel(user_agents, worker_count)
                end
      success ? 0 : 1
    rescue ex : Exception
      @error.puts "Error: #{ex.message || ex.class.name}"
      1
    end

    private def read_user_agents(positional : Array(String)) : Array(String)
      user_agents = [] of String

      if positional.empty?
        append_lines(@input, user_agents)
      else
        positional.each do |argument|
          if argument == "-"
            append_lines(@input, user_agents)
          else
            argument.each_line { |line| append_line(line, user_agents) }
          end
        end
      end

      user_agents
    end

    private def append_lines(input : IO, user_agents : Array(String)) : Nil
      input.each_line { |line| append_line(line, user_agents) }
    end

    private def append_line(line : String, user_agents : Array(String)) : Nil
      user_agent = line.strip
      user_agents << user_agent unless user_agent.empty?
    end

    private def parse_sequential(user_agents : Array(String)) : Bool
      success = true
      user_agents.each_with_index do |user_agent, index|
        emitted = emit(parse_one(index, user_agent))
        success = false unless emitted
      end
      success
    end

    private def parse_parallel(user_agents : Array(String), worker_count : Int32) : Bool
      channel_capacity = worker_count * 2
      jobs = Channel(WorkItem).new(channel_capacity)
      results = Channel(ParseResult).new(channel_capacity)
      producer_done = WaitGroup.new(1)
      workers_done = WaitGroup.new(worker_count)
      context = Fiber::ExecutionContext::Parallel.new("device-detector-cli", worker_count)

      worker_count.times do
        context.spawn do
          while item = jobs.receive?
            results.send(parse_one(item.index, item.user_agent))
          end
        ensure
          workers_done.done
        end
      end

      spawn do
        user_agents.each_with_index do |user_agent, index|
          jobs.send(WorkItem.new(index, user_agent))
        end
      ensure
        jobs.close
        producer_done.done
      end

      success = emit_in_order(results, user_agents.size)
      producer_done.wait
      workers_done.wait
      success
    end

    private def emit_in_order(results : Channel(ParseResult), count : Int32) : Bool
      pending = {} of Int32 => ParseResult
      next_index = 0
      success = true

      count.times do
        result = results.receive
        pending[result.index] = result

        while current = pending.delete(next_index)
          emitted = emit(current)
          success = false unless emitted
          next_index += 1
        end
      end

      success
    end

    private def parse_one(index : Int32, user_agent : String) : ParseResult
      response = DeviceDetector::Detector.new(user_agent).call
      ParseResult.new(index, response_json(user_agent, response), nil)
    rescue ex : Exception
      ParseResult.new(index, "", ex.message || ex.class.name)
    end

    private def emit(result : ParseResult) : Bool
      if message = result.error
        @error.puts "Error: input #{result.index + 1}: #{message}"
        false
      else
        @output.puts result.json
        true
      end
    end

    private def response_json(user_agent : String, response : DeviceDetector::Response) : String
      JSON.build do |json|
        json.object do
          json.field "user_agent", user_agent
          json.field "traffic_type", response.traffic_type

          response.raw.each do |section_result|
            section_result.each do |section, fields|
              next unless fields.any? { |_name, value| !value.blank? }

              json.field section do
                json.object do
                  fields.each do |name, value|
                    json.field name, value unless value.blank?
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
