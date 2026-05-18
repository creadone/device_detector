require "http/client"
require "file_utils"
require "compress/zip"
require "set"
require "yaml"

REMOTE_REPO_URL = "https://codeload.github.com/matomo-org/device-detector/zip/refs/heads/master"
REGEXES_PATH    = "/regexes/"
TOKEN_REGEX     = /[A-Za-z0-9][A-Za-z0-9._+-]{2,}/
MAX_TOKEN_RULES = 250
IGNORED_TOKENS  = Set{
  "mozilla",
  "applewebkit",
  "khtml",
  "like",
  "gecko",
  "version",
  "mobile",
  "safari",
  "build",
  "compatible",
  "windows",
  "linux",
}

struct IndexedRule
  include YAML::Serializable

  property regex : String
end

def indexed_tokens(pattern)
  tokens = pattern.scan(TOKEN_REGEX).map(&.[0].downcase)
  tokens.uniq!
  tokens.reject do |token|
    IGNORED_TOKENS.includes?(token)
  end
end

def add_index_entry(index, token, rule_index)
  index[token] ||= [] of Int32
  index[token] << rule_index
end

def add_rule_to_index(index, rule_index, pattern)
  indexed_tokens(pattern).each do |token|
    add_index_entry(index, token, rule_index)
  end
end

def prune_index(index)
  index.each do |token, indexes|
    index.delete(token) if indexes.size > MAX_TOKEN_RULES
  end
end

def write_index(path, index)
  File.open(path, "w") do |io|
    tokens = index.keys
    tokens.sort!

    tokens.each do |token|
      io << token << ":\n"
      rule_indexes = index[token].uniq
      rule_indexes.sort!

      rule_indexes.each do |rule_index|
        io << "  - " << rule_index << "\n"
      end
    end
  end
end

def build_array_index(regexes_dir, relative_path)
  index = {} of String => Array(Int32)
  rules = Array(IndexedRule).from_yaml(File.read(File.join(regexes_dir, relative_path)))

  rules.each_with_index do |rule, rule_index|
    add_rule_to_index(index, rule_index, rule.regex)
  end

  prune_index(index)
  index
end

def build_hash_index(regexes_dir, relative_path)
  index = {} of String => Array(Int32)
  document = YAML.parse(File.read(File.join(regexes_dir, relative_path))).as_h

  document.each_with_index do |(_vendor, rule), rule_index|
    pattern = rule["regex"]?.try(&.as_s?)
    next unless pattern

    add_rule_to_index(index, rule_index, pattern)
  end

  prune_index(index)
  index
end

def build_regex_indexes(regexes_dir)
  index_dir = File.join(regexes_dir, "index")
  FileUtils.rm_rf(index_dir)
  Dir.mkdir_p(index_dir)

  write_index(File.join(index_dir, "bots.yml"), build_array_index(regexes_dir, "bots.yml"))
  write_index(File.join(index_dir, "browsers.yml"), build_array_index(regexes_dir, "client/browsers.yml"))
  write_index(File.join(index_dir, "oss.yml"), build_array_index(regexes_dir, "oss.yml"))
  write_index(File.join(index_dir, "mobiles.yml"), build_hash_index(regexes_dir, "device/mobiles.yml"))
end

local_tmp_dir_path = Dir.tempdir
local_archive_path = File.join(local_tmp_dir_path, "matomo-device-detector-regexes.zip")
local_regexes_dir = File.expand_path("../src/device_detector/regexes", __DIR__)

HTTP::Client.get(REMOTE_REPO_URL) do |response|
  unless response.success?
    raise "Could not download regexes archive: HTTP #{response.status_code} #{response.status_message}"
  end

  File.write(local_archive_path, response.body_io)
end

if File.exists?(local_archive_path) && File.size(local_archive_path) > 0
  Compress::Zip::File.open(local_archive_path) do |file|
    regexes = file.entries.compact_map do |entry|
      next unless entry.filename.ends_with?(".yml")

      regexes_path_start = entry.filename.index(REGEXES_PATH)
      next unless regexes_path_start

      relative_path_start = regexes_path_start + REGEXES_PATH.size
      relative_path = entry.filename[relative_path_start..]
      next if relative_path.empty?

      {entry, relative_path}
    end

    raise "Regexes archive does not contain any regexes/*.yml files" if regexes.empty?

    FileUtils.rm_rf(local_regexes_dir)
    Dir.mkdir_p(local_regexes_dir)

    regexes.each do |entry, relative_category_path|
      destination_file_path = File.join(local_regexes_dir, relative_category_path)
      destination_dir_path = File.dirname(destination_file_path)

      Dir.mkdir_p(destination_dir_path)
      entry.open { |io| File.write(destination_file_path, io.gets_to_end) }
    end

    File.delete(local_archive_path)
  end
else
  raise "Regexes repo not found"
end

build_regex_indexes(local_regexes_dir)

puts "Updated"
puts "Don't forget run `crystal spec`"
