# Device Detector

The library for parse User Agent detect and the browser, operating system, device used (desktop, tablet, mobile, tv, cars, console, etc.), vendor and model.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  DeviceDetector:
    github: creadone/device_detector
```

## Usage

```crystal
require "device_detector"

"Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
response = DeviceDetector::Detector.new(user_agent).call

# Check client type
response.mobile? #=> false

# Check browser
response.browser? #=> true
response.browser_name #=> Microsoft Edge
response.browser_version #=> 12.0

# If you need to get all about client info
response.raw

#=> ...
```

## Testing

```
crystal spec
```

## Contributing

1. Fork it ( https://github.com/[your-github-name]/DeviceDetector/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[@creadone]](https://github.com/creadone) Sergey Fedorov - creator, maintainer
