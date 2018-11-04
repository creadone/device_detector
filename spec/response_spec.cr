require "./spec_helper"

describe "Response" do
  describe "Base methods" do
    user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return any data in expected structure" do
      response.raw.should be_truthy
      response.raw.should be_a(Array(Hash(String, Hash(String, String))))
    end
  end

  describe "Bot" do
    user_agent = "Googlebot (gocrawl v0.4)"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if bot detected" { response.bot?.should be_true }
    it "should return bot name" { response.bot_name.should eq("Googlebot") }
  end

  describe "BrowserEngine" do
    user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if engine detected" { response.browser_engine?.should be_true }
    it "should return engine name" { response.browser_engine_name.should eq "Edge" }
  end

  describe "Browser" do
    user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if browser detected" { response.browser?.should be_true }
    it "should return browser name" { response.browser_name.should eq "Microsoft Edge" }
    it "should return browser version" { response.browser_version.should eq "12.0" }
  end

  describe "Camera" do
    user_agent = "Mozilla/5.0 (Linux; U; Android 2.3.3; ja-jp; COOLPIX S800c Build/CP01_WW) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if camera detected" { response.camera?.should be_true }
    it "should return camera vendor" { response.camera_vendor.should eq "Nikon" }
    it "should return camera model" { response.camera_model.should eq "Coolpix S800c" }
  end

  describe "CarBrowser" do
    user_agent = "Mozilla/5.0 (X11; u; Linux; C) AppleWebKit /533.3 (Khtml, like Gheko) QtCarBrowser Safari/533.3"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if car browser detected" { response.car_browser?.should be_true }
    it "should return car browser vendor" { response.car_browser_vendor.should eq "Tesla" }
    it "should return car browser model" { response.car_browser_model.should eq "Model S" }
  end

  describe "Console" do
    user_agent = "Mozilla/5.0 (PLAYSTATION 3 4.46) AppleWebKit/531.22.8 (KHTML, like Gecko)"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if console detected" { response.console?.should be_true }
    it "should return console vendor" { response.console_vendor.should eq "Sony" }
    it "should return console model" { response.console_model.should eq "PlayStation 3" }
  end

  describe "FeedReader" do
    user_agent = "FeeddlerRSS/2.4 CFNetwork/548.1.4 Darwin/11.0.0"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if feedreader detected" { response.feed_reader?.should be_true }
    it "should return name" { response.feed_reader_name.should eq "Feeddler RSS Reader" }
    it "should return version" { response.feed_reader_version.should eq "2.4" }
  end

  describe "Library" do
    user_agent = "curl/7.21.0 (i386-redhat-linux-gnu) libcurl/7.21.0 NSS/3.12.10.0 zlib/1.2.5 libidn/1.18 libssh2/1.2.4"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if library detected" { response.library?.should be_true }
    it "should return name" { response.library_name.should eq "curl" }
    it "should return version" { response.library_version.should eq "7.21.0" }
  end

  describe "Mediaplayer" do
    user_agent = "iTunes/10.2.1 (Macintosh; Intel Mac OS X 10.7) AppleWebKit/534.20.8"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if mediaplayer detected" { response.mediaplayer?.should be_true }
    it "should return name" { response.mediaplayer_name.should eq "iTunes" }
    it "should return version" { response.mediaplayer_version.should eq "10.2.1" }
  end

  describe "MobileApp" do
    user_agent = "WhatsApp/2.6.4 iPhone_OS/4.3.3 Device/iPhone_4"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if mobile app detected" { response.mobile_app?.should be_true }
    it "should return name" { response.mobile_app_name.should eq "WhatsApp" }
    it "should return version" { response.mobile_app_version.should eq "2.6.4" }
  end

  describe "MobileDevice" do
    user_agent = "Mozilla/5.0 (Linux; Android 7.0; BV6000 Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 YaBrowser/17.1.1.359.00 Mobile Safari/537.36"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if mobile device detected" { response.mobile_device?.should be_true }
    it "should return vendor" { response.mobile_device_vendor.should eq "Blackview" }
    it "should return type" { response.mobile_device_type.should eq "smartphone" }
    it "should return model" { response.mobile_device_model.should eq "BV6000" }
  end

  describe "OS" do
    user_agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.8) Gecko Fedora/1.9.0.8-1.fc10 Kazehakase/0.5.6"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if OS detected" { response.os?.should be_true }
    it "should return name" { response.os_name.should eq "Fedora" }
    it "should return version" { response.os_version.should eq "1.9.0.8" }
  end

  describe "PIM" do
    user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Win64; x64; Trident/7.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; InfoPath.3; .NET CLR 1.1.4322; FDM; Tablet PC 2.0; .NET4.0E; Microsoft Outlook 14.0.7113; ms-office; MSOffice 14)"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if PIM detected" { response.pim?.should be_true }
    it "should return name" { response.pim_name.should eq "Microsoft Outlook" }
    it "should return version" { response.pim_version.should eq "14.0.7113" }
  end

  describe "PortableMediaPlayer" do
    user_agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.12; Microsoft ZuneHD 4.3)"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if PIM detected" { response.portable_media_player?.should be_true }
    it "should return vendor" { response.portable_media_player_vendor.should eq "Microsoft" }
    it "should return model" { response.portable_media_player_model.should eq "Zune HD" }
  end

  describe "TV" do
    user_agent = "Opera/9.80 (Linux armv7l; HbbTV/1.2.1 (; Hisense; SmartTV_2015; V00.01.00a.G0816; HE65M7000UWTSG; )) Presto/2.12.407 Version/12.51 year/2016"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if TV detected" { response.tv?.should be_true }
    it "should return vendor" { response.tv_vendor.should eq "Hisense" }
    it "should return model" { response.tv_model.should eq "HE65M7000UWTS" }
  end

  describe "VendorFragment" do
    user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/7.0; SLCC2; .NET CLR 2.0.50727; Media Center PC 6.0; MAAR; Tablet PC 2.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E)"
    response = DeviceDetector::Detector.new(user_agent).call
    it "should return true if VendorFragment detected" { response.vendorfragment?.should be_true }
    it "should return vendor" { response.vendorfragment_vendor.should eq "Acer" }
  end

  describe "TrafficType" do
    describe "Bot" do
      user_agent = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
      response = DeviceDetector::Detector.new(user_agent).call
      it "should return true if traffic from bot" { response.traffic_type.should eq "bot" }
    end

    describe "Human" do
      user_agent = "Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X; en-us) AppleWebKit/534.46 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53"
      response = DeviceDetector::Detector.new(user_agent).call
      it "should return true if traffic from human" { response.traffic_type.should eq "human" }
    end
  end
end
