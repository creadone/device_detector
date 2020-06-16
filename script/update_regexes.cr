require "http/client"
require "file_utils"
require "zip"

remote_repo_url = "https://codeload.github.com/matomo-org/device-detector/zip/master"
repo_archive_name = File.basename(remote_repo_url)

local_tmp_dir_path = Dir.tempdir
local_archive_path = File.join(local_tmp_dir_path, "#{repo_archive_name}.zip")
local_regexes_dir = "./src/device_detector/regexes"

HTTP::Client.get(remote_repo_url) do |response|
  File.write(local_archive_path, response.body_io)
end

if File.exists?(local_archive_path)
  Zip::File.open(local_archive_path) do |file|
    yamls = file.entries.select { |e| e.filename.includes?("yml") }

    yamls.each do |entry|
      relative_category_path = entry.filename.split("/regexes/").last
      destination_file_path = File.join(local_regexes_dir, relative_category_path)
      destination_dir_path = File.dirname(destination_file_path)

      Dir.mkdir_p(destination_dir_path) unless Dir.exists?(destination_dir_path)
      entry.open { |io| File.write(destination_file_path, io.gets_to_end) }
    end

    File.delete(local_archive_path)
  end
else
  raise "Regexes repo not found"
end

puts "Updated"
puts "Don't forget run `Crystal spec`"
