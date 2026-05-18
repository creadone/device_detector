# Device Detector

[English version](README.md)

Device Detector - Crystal shard для разбора строк `User-Agent`. Он определяет ботов, браузеры, движки браузеров, операционные системы, клиентские приложения, устройства, производителей, модели и несколько специализированных классов устройств: телевизоры, камеры, консоли, автомобильные браузеры и портативные медиаплееры.

Парсер использует regex-данные из [matomo-org/device-detector](https://github.com/matomo-org/device-detector), генерирует token indexes для самых крупных наборов правил и встраивает regexes и indexes в shard на этапе компиляции.

## Установка

Добавьте shard в `shard.yml` приложения:

```yaml
dependencies:
  device_detector:
    github: creadone/device_detector
```

Затем установите зависимости:

```sh
shards install
```

## Использование

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

Используйте `#call`, чтобы запустить полный стек парсеров. Используйте `#lite`, если нужны только определение бота и мобильного устройства:

```crystal
full_response = DeviceDetector::Detector.new(user_agent).call
lite_response = DeviceDetector::Detector.new(user_agent).lite
```

`Response#raw` возвращает сырой результат парсеров:

```crystal
pp response.raw
```

Сырое значение имеет тип `Array(Hash(String, Hash(String, String)))`. Отсутствующие значения представлены пустыми строками в raw-данных; типизированные accessors возвращают `String?`.

## Response API

У каждой обнаруживаемой секции есть predicate и object-style accessor:

```crystal
response.browser?        # => Bool
response.browser.name    # => String?
response.browser.version # => String?
```

Доступные секции и поля:

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

Legacy flat accessors остаются доступными для совместимости:

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

`Response#traffic_type` возвращает `"bot"`, если обнаружен бот или клиентская библиотека. В остальных случаях возвращается `"human"`.

```crystal
response.traffic_type # => "bot" | "human"
```

## Benchmarks

Запуск benchmark в release mode:

```sh
crystal run --release bench/raw_response.cr
```

Пример результата для разбора 10 000 уникальных user-agent строк:

```text
Crystal 1.17.1 (2025-07-22)
LLVM: 21.1.0
Default target: aarch64-apple-darwin23.1.0

workload: 10000 unique user-agents
full:  7807.40 user-agent/sec (1.280836s)
lite: 28040.29 user-agent/sec (0.356630s)
```

Benchmark требует минимальную скорость full parser в 150 user-agent/sec.

Парсер хранит generated token indexes для самых больших и быстрорастущих наборов правил: bots, browsers, operating systems и mobile devices. Индексы сужают список regex-кандидатов перед fallback на полный scan правил и при этом сохраняют исходный приоритет YAML-правил.

## Разработка

Установите зависимости:

```sh
shards install
```

Запустите тесты:

```sh
crystal spec
```

Запустите linter:

```sh
bin/ameba
```

Проверьте форматирование:

```sh
crystal tool format --check src spec script bench
```

## Обновление Regexes

Regex-файлы лежат в `src/device_detector/regexes` и основаны на `matomo-org/device-detector`.

Чтобы обновить их:

```sh
crystal run script/update_regexes.cr
crystal spec
bin/ameba
```

Скрипт обновления скачивает upstream regexes, зеркалит только `regexes/**/*.yml` и пересоздает token indexes в `src/device_detector/regexes/index`. Перед коммитом нужно проверить и закоммитить diff regexes вместе с diff generated indexes.

## Contributing

1. Сделайте fork репозитория.
2. Создайте feature branch.
3. Внесите изменение и добавьте тесты, если меняется поведение.
4. Запустите `crystal spec`, `bin/ameba` и проверку форматирования.
5. Откройте pull request.

## Contributors

- [@creadone](https://github.com/creadone) Sergey Fedorov - creator, maintainer
- [@delef](https://github.com/delef) Ivan Palamarchuk - new API, code optimization
- [@zaycker](https://github.com/zaycker) Yuriy Zaitsev - parser order fix
