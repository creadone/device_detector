module DeviceDetector
  struct Storage
    @@container = {} of String => String
    @@ready_to_use = false

    def self.setup_regexes
      Dir.glob(File.join(Setting::REGEXES_PATH, "**/*.yml")).each do |path|
        name = File.basename(path)
        @@container[name] = File.read(path)
      end
      @@ready_to_use = true
    end

    def self.get(file_name : String)
      if @@ready_to_use
        @@container[file_name]
      else
        self.setup_regexes
        @@container[file_name]
      end
    end
  end
end
