module DeviceDetector
  struct Storage
    @@container = {} of String => String

    def self.setup_regexes
      Dir.glob(File.join(Setting::REGEXES_PATH, "**/*.yml")).each do |path|
        name = File.basename(path)
        @@container[name] = File.read(path)
      end
    end

    def self.get(file_name : String)
      @@container[file_name]
    end

    self.setup_regexes
  end
end
