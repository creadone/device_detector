# Device Detector

[![Build Status](https://travis-ci.org/creadone/device_detector.svg?branch=master)](https://travis-ci.org/creadone/device_detector)

The library for parsing User Agent and browser, operating system, device used (desktop, tablet, mobile, tv, cars, console, etc.), vendor and model detection.

* Support latest Crystal version and update script for private use or immediately updates.
* Currently it is production version and works fine more that 2 years.
* The Library uses regexes from [matomo-org/device-detector](https://github.com/matomo-org/device-detector).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  device_detector:
    github: creadone/device_detector
```

Then run `shards install`

## Usage

```Crystal
require "device_detector"

user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
response = DeviceDetector::Detector.new(user_agent).call  # All parsers
response = DeviceDetector::Detector.new(user_agent).lite  # Only for bot and mobile

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

  {...},

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

Run the benchmark in release mode:

```sh
crystal run --release bench/raw_response.cr
```

Recent benchmark of parsing 10,000 unique user-agent strings:

Crystal 1.17.1 (2025-07-22)
LLVM: 21.1.0
Default target: aarch64-apple-darwin23.1.0

```
workload: 10000 unique user-agents
full:  3209.13 user-agent/sec (3.116112s)
lite: 10856.07 user-agent/sec (0.921143s)
```

The benchmark also enforces a minimum full parser speed of 150 user-agent/sec.

## Testing

```
crystal spec
```

## Update regexes

```
crystal scripts/update_regexes.cr
```

## ToDo

* Support [overloading of base rules](https://github.com/matomo-org/device-detector/issues/5962)
* CLI & HTTP version
* More lighter and faster the `lite` version
* Reload regexes on the fly (may be)

## Contributing

1. Fork it ( https://github.com/creadone/device_detector/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [@creadone](https://github.com/creadone) Sergey Fedorov - creator, maintainer
- [@delef](https://github.com/delef) Ivan Palamarchuk - new api, code optimization
- [@zaycker](https://github.com/zaycker) Yuriy Zaitsev - fix check order
