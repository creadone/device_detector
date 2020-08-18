require "baked_file_system"

module DeviceDetector
  struct Storage
    extend BakedFileSystem

    INSTANCE = new

    def self.instance
      INSTANCE
    end

    bake_folder "./regexes"
    bake_folder "./regexes/client"
    bake_folder "./regexes/device"

    def self.get(path)
      find_file(path).as(BakedFileSystem::BakedFile).gets_to_end
    end

    def self.find_file(path)
      path = path.strip
      path = "/" + path unless path.starts_with?("/")

      file = @@files.find do |file|
        file.path == path
      end

      return nil unless file

      file.rewind
      file
    end

  end
end
