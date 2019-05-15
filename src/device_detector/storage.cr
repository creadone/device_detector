require "baked_file_system"

module DeviceDetector
  struct Storage
    extend BakedFileSystem

    bake_folder "./regexes"
    bake_folder "./regexes/client"
    bake_folder "./regexes/device"
  end
end
