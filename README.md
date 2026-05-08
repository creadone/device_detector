# Device Detector

Device Detector is a Crystal shard for parsing `User-Agent` strings. It detects bots, browsers, browser engines, operating systems, client applications, devices, vendors, models, and a few specialized device classes such as TVs, cameras, consoles, car browsers, and portable media players.

The parser uses regex data from [matomo-org/device-detector](https://github.com/matomo-org/device-detector) and embeds it into the shard at compile time.

## Installation

Add the shard to your application's `shard.yml`:

```yaml
dependencies:
  device_detector:
    github: creadone/device_detector
```

Then install dependencies:

```sh
shards install
```

## Usage

```crystal
require "device_detector"

user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"

response = DeviceDetector::Detector.new(user_agent).call

response.browser?             # => true
response.browser.name         # => "Microsoft Edge"
response.browser.version      # => "12.0"
response.os.name              # => "Windows"
response.os.version           # => "10"
response.traffic_type         # => "human"
```

Use `#call` to run the full parser stack. Use `#lite` when you only need bot and mobile-device detection:

```crystal
full_response = DeviceDetector::Detector.new(user_agent).call
lite_response = DeviceDetector::Detector.new(user_agent).lite
```

`Response#raw` returns the raw parser output:

```crystal
pp response.raw
```

The raw value is an `Array(Hash(String, Hash(String, String)))`. Missing values are represented as empty strings in the raw data; typed accessors return `String?`.

## Response API

Each detected section has a predicate and an object-style accessor:

```crystal
response.browser?        # => Bool
response.browser.name    # => String?
response.browser.version # => String?
```

Available sections and fields:

| Section | Predicate | Fields |
| --- | --- | --- |
| Bot | `bot?` | `bot.name` |
| Browser | `browser?` | `browser.name`, `browser.version` |
| Browser engine | `browser_engine?` | `browser_engine.name` |
| Camera | `camera?` | `camera.device`, `camera.vendor` |
| Car browser | `car_browser?` | `car_browser.model`, `car_browser.vendor` |
| Console | `console?` | `console.model`, `console.vendor` |
| Feed reader | `feed_reader?` | `feed_reader.name`, `feed_reader.version` |
| Library | `library?` | `library.name`, `library.version` |
| Mediaplayer | `mediaplayer?` | `mediaplayer.name`, `mediaplayer.version` |
| Mobile app | `mobile_app?` | `mobile_app.name`, `mobile_app.version` |
| Mobile device | `mobile?` | `mobile.vendor`, `mobile.type`, `mobile.model` |
| OS | `os?` | `os.name`, `os.version` |
| PIM | `pim?` | `pim.name`, `pim.version` |
| Portable media player | `portable_media_player?` | `portable_media_player.model`, `portable_media_player.vendor` |
| TV | `tv?` | `tv.model`, `tv.vendor` |
| Vendor fragment | `vendorfragment?` | `vendorfragment.vendor` |

Legacy flat accessors are still available for compatibility:

```crystal
response.browser_name
response.browser_version
response.mobile_device?
response.mobile_device_vendor
response.mobile_device_type
response.mobile_device_model
response.camera_model
```

## Traffic Type

`Response#traffic_type` returns `"bot"` when a bot or client library was detected. Otherwise it returns `"human"`.

```crystal
response.traffic_type # => "bot" | "human"
```

## Benchmarks

Run benchmarks in release mode:

```sh
crystal run --release bench/raw_response.cr
```

Example result for parsing 10,000 unique user-agent strings:

```text
Crystal 1.17.1 (2025-07-22)
LLVM: 21.1.0
Default target: aarch64-apple-darwin23.1.0

workload: 10000 unique user-agents
full:  4409.90 user-agent/sec (2.267623s)
lite: 11332.39 user-agent/sec (0.882426s)
```

The benchmark enforces a minimum full-parser speed of 150 user-agent/sec.

## Development

Install dependencies:

```sh
shards install
```

Run tests:

```sh
crystal spec
```

Run the linter:

```sh
bin/ameba
```

Check formatting:

```sh
crystal tool format --check src spec script bench
```

## Updating Regexes

Regex files live under `src/device_detector/regexes` and are based on `matomo-org/device-detector`.

To refresh them:

```sh
crystal run script/update_regexes.cr
crystal spec
bin/ameba
```

Review the regex diff before committing it.

## Contributing

1. Fork the repository.
2. Create a feature branch.
3. Make the change with tests when behavior changes.
4. Run `crystal spec`, `bin/ameba`, and the formatter check.
5. Open a pull request.

## Contributors

- [@creadone](https://github.com/creadone) Sergey Fedorov - creator, maintainer
- [@delef](https://github.com/delef) Ivan Palamarchuk - new API, code optimization
- [@zaycker](https://github.com/zaycker) Yuriy Zaitsev - parser order fix
