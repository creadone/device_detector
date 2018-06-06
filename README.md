# Device Detector

The library for parse User Agent detect and the browser, operating system, device used (desktop, tablet, mobile, tv, cars, console, etc.), vendor and model.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  device_detector:
    github: creadone/device_detector
```

## Usage

```crystal
require "device_detector"

"Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
response = DeviceDetector::Detector.new(user_agent).call

# Check if browser detected
response.browser? #=> true
response.browser_name #=> Microsoft Edge
response.browser_version #=> 12.0

# If you need to get all info
response.raw
#=> [{"browser" => {"name" => "Microsoft Edge", "version" => "12.0"}},
#    {"browser_engine" => {"name" => "Edge"}},
#    {"oss" => {"name" => "Windows", "version" => "10"}}]
```

## Testing

`crystal spec`

## Contributing

1. Fork it ( https://github.com/creadone/device_detector/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[@creadone]](https://github.com/creadone) Sergey Fedorov - creator, maintainer
