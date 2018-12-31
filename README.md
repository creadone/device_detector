# Device Detector

[![Build Status](https://travis-ci.org/creadone/device_detector.svg?branch=master)](https://travis-ci.org/creadone/device_detector)

The library for parsing User Agent and browser, operating system, device used (desktop, tablet, mobile, tv, cars, console, etc.), vendor and model detection. Currently it is an alpha-version and haven't been tested on production yet. The Library uses regexes from [matomo-org/device-detector](https://github.com/matomo-org/device-detector).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  device_detector:
    github: creadone/device_detector
```

Then run `shards`

## Usage

```Crystal
require "device_detector"

user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
response = DeviceDetector::Detector.new(user_agent).call # For use all parsers
response = DeviceDetector::Detector.new(user_agent).lite  # For use only bot and mobile

# Check if browser detected
response.browser? #=> true

# browser name
response.browser_name #=> Microsoft Edge

# browser version
response.browser_version #=> 12.0

# get raw response with
pp response.raw

[{
    "bot" => {
      "name" => ""
    }
  },
  {
    "browser" => {
      "name" => "", "version" => ""
    }
  },
  {
    "browser_engine" => {
      "name" => ""
    }
  },
  {
    "camera" => {
      "vendor" => "", "model" => "", "device" => ""
    }
  },
  {
    "car_browser" => {
      "vendor" => "", "device" => "", "model" => ""
    }
  },
  {
    "console" => {
      "vendor" => "", "model" => ""
    }
  },
  {
    "feed_reader" => {
      "name" => "", "version" => ""
    }
  },
  {
    "library" => {
      "name" => "", "version" => ""
    }
  },
  {
    "mediaplayer" => {
      "name" => "", "version" => ""
    }
  },
  {
    "mobile_app" => {
      "name" => "", "version" => ""
    }
  },
  {
    "mobile" => {
      "device" => "", "vendor" => "", "type" => ""
    }
  },
  {
    "oss" => {
      "name" => "", "version" => ""
    }
  },
  {
    "pim" => {
      "name" => "", "version" => ""
    }
  },
  {
    "portable_media_player" => {
      "vendor" => "", "model" => ""
    }
  },
  {
    "tv" => {
      "model" => "", "vendor" => ""
    }
  },
  {
    "vendorfragment" => {
      "vendor" => ""
    }
  }
]

```

Available methods:

<table>
  <tr>
    <td>bot?<br />bot_name</td>
    <td>browser_engine?<br />browser_engine_name</td>
    <td>browser?<br />browser_name<br />browser_version</td>
    <td>camera?<br />camera_vendor<br />camera_model</td>
  </tr>
  <tr>
    <td>car_browser?<br />car_browser_vendor<br />car_browser_model</td>
    <td>console?<br />console_vendor<br />console_model</td>
    <td>feed_reader?<br />feed_reader_name<br />feed_reader_version</td>
    <td>library?<br />library_name<br />library_version</td>
  </tr>
  <tr>
    <td>mediaplayer?<br />mediaplayer_name<br />mediaplayer_version</td>
    <td>mobile_app?<br />mobile_app_name<br />mobile_app_version</td>
    <td>mobile_device?<br />mobile_device_vendor<br />mobile_device_type<br />mobile_device_model</td>
    <td>os?<br />os_name<br />os_version</td>
  </tr>
  <tr>
    <td>pim?<br />pim_name<br />pim_version</td>
    <td>portable_media_player?<br />portable_media_player_vendor<br />portable_media_player_model</td>
    <td>tv?<br />tv_vendor<br />tv_model</td>
    <td>vendorfragment?<br />vendorfragment_vendor</td>
  </tr>
</table>

## Benchmarks

Recent benchmarking of parsing 1000 user-agent strings on a MacBook Air with Intel Core i5 dual core (0.8 Ghz per core):

```
bench/raw_response.cr --release
            user     system      total        real
full:   6.770000   0.100000   6.870000 (  6.805766)
lite:   5.370000   0.080000   5.450000 (  5.378346)
```

It's mean that `device_detector` can work with 1000 / 6.8 ~ 147 QPS.

## Testing

```
crystal spec
```

## Contributing

1. Fork it ( https://github.com/creadone/device_detector/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [@creadone](https://github.com/creadone) Sergey Fedorov - creator, maintainer
- [@delef](https://github.com/delef) Ivan Palamarchuk - code optimization
