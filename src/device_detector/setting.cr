module DeviceDetector
  module Setting
    # Built-in parser classes accepted by `DeviceDetector.prepare`.
    alias ParserClass = Parser::Bot.class |
                        Parser::Browser.class |
                        Parser::BrowserEngine.class |
                        Parser::Camera.class |
                        Parser::CarBrowser.class |
                        Parser::Console.class |
                        Parser::FeedReader.class |
                        Parser::Library.class |
                        Parser::Mediaplayer.class |
                        Parser::MobileApp.class |
                        Parser::Mobile.class |
                        Parser::OS.class |
                        Parser::PIM.class |
                        Parser::PortableMediaPlayer.class |
                        Parser::Television.class |
                        Parser::VendorFragment.class

    # Full parser set
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
    ] of ParserClass

    # Only for bot and mobile device detection
    LITE = [
      Parser::Bot,
      Parser::Mobile,
    ] of ParserClass

    # Regex options
    REGEX_OPTS = Regex::Options::IGNORE_CASE
  end
end
