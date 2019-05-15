require "baked_file_system"

module DeviceDetector
  struct Storage
    extend BakedFileSystem

    regexes = Dir.glob("./src/device_detector/regexes/**/*.yml")
    regexes.each do |path|
      bake_file File.basename(path), File.read(path)
    end
  end
end
