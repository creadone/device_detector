require "baked_file_system"

module DeviceDetector
  class Storage
    extend BakedFileSystem
    bake_folder "./regexes"
  end
end
