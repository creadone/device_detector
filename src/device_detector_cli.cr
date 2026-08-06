require "./device_detector/cli/command"

exit DeviceDetector::CLI::Command.new.run(ARGV)
