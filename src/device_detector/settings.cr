module DeviceDetector
  module Settings
    # Full complect
    FULL = [
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

    # Only for bot and mobile device detection
    LITE = [
      BotStore,
      MobileStore,
    ]

    # Regex options
    REGEX_OPTS = Regex::Options::IGNORE_CASE
  end
end
