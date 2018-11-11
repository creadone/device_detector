require "baked_file_system"

module DeviceDetector
  struct Storage
    extend BakedFileSystem
    bake_folder "./regexes"
  end
end
