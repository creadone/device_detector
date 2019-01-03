require "baked_file_system"

module DeviceDetector
  struct Storage
    extend BakedFileSystem
    bake_folder "./regex"
  end
end
