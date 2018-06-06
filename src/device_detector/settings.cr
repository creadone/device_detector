module DeviceDetector
  module Settings
    # Used parsers
    PARSERS = [
      BotStore,
      BrowserStore,
      BrowserEngineStore,
      CameraStore,
      CarBrowserStore,
      ConsoleStore,
      FeedReaderStore,
      LibraryStore,
      MediaplayerStore,
      MobileAppStore,
      MobileStore,
      OSSStore,
      PIMStore,
      PortableMediaPlayerStore,
      TelevisionStore,
      VendorFragmentStore,
    ]

    # Regex options
    REGEX_OPTS = Regex::Options::IGNORE_CASE
  end
end
