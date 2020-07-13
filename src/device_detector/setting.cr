module DeviceDetector
  module Setting
    # Full complect
    FULL = [
      Parser::Bot,
      Parser::Browser,
      Parser::BrowserEngine,
      Parser::Camera,
      Parser::CarBrowser,
      Parser::Console,
      Parser::FeedReader,
      Parser::Library,
      Parser::Mediaplayer,
      Parser::MobileApp,
      Parser::Mobile,
      Parser::OS,
      Parser::PIM,
      Parser::PortableMediaPlayer,
      Parser::Television,
      Parser::VendorFragment,
    ]

    # Only for bot and mobile device detection
    LITE = [
      Parser::Bot,
      Parser::Mobile,
    ]

    # Regex options
    REGEX_OPTS = Regex::Options::IGNORE_CASE

    REGEXES_PATH = "./regexes"
  end
end
