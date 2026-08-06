require "./spec_helper"
require "../src/device_detector/parser"
require "fiber/execution_context"
require "wait_group"

describe "In the parsers" do
  describe "Bot" do
    it "should extract bot name" do
      user_agent = "Googlebot (gocrawl v0.4)"
      detector = DeviceDetector::Parser::Bot.new user_agent
      detector.call["name"].should eq "Googlebot"
    end

    it "keeps bot decisions stable across parallel workers after preparation" do
      DeviceDetector::Parser::Bot.prepare
      context = Fiber::ExecutionContext::Parallel.new("bot-parser-spec", 4)
      workers = WaitGroup.new(100)
      failures = Atomic(Int32).new(0)
      user_agent = "Googlebot (gocrawl v0.4)"

      100.times do
        context.spawn do
          result = DeviceDetector::Parser::Bot.new(user_agent).call
          failures.add(1, :relaxed) unless result["name"] == "Googlebot"
        ensure
          workers.done
        end
      end

      workers.wait
      failures.get(:relaxed).should eq(0)
    end
  end

  describe "BrowserEngine" do
    it "should extract engine name" do
      user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
      detector = DeviceDetector::Parser::BrowserEngine.new user_agent
      detector.call["name"].should eq "Edge"
    end
  end

  describe "Browser" do
    it "should extract browser name and version" do
      user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
      detector = DeviceDetector::Parser::Browser.new user_agent
      result = detector.call
      result["name"].should eq "Microsoft Edge"
      result["version"].should eq "12.0"
    end
  end

  describe "Camera" do
    it "should extract vendor and device" do
      user_agent = "Mozilla/5.0 (Linux; U; Android 2.3.3; ja-jp; COOLPIX S800c Build/CP01_WW) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
      detector = DeviceDetector::Parser::Camera.new user_agent
      result = detector.call
      result["vendor"].should eq "Nikon"
      result["device"].should eq "Coolpix S800c"
    end
  end

  describe "CarBrowser" do
    it "should extract model name and vendor" do
      user_agent = "Mozilla/5.0 (X11; u; Linux; C) AppleWebKit /533.3 (Khtml, like Gheko) QtCarBrowser Safari/533.3"
      detector = DeviceDetector::Parser::CarBrowser.new user_agent
      result = detector.call
      result["model"].should eq "Model S"
      result["vendor"].should eq "Tesla"
    end
  end

  describe "Console" do
    it "should extract vendor and model name" do
      user_agent = "Mozilla/5.0 (PLAYSTATION 3 4.46) AppleWebKit/531.22.8 (KHTML, like Gecko)"
      detector = DeviceDetector::Parser::Console.new user_agent
      result = detector.call
      result["vendor"].should eq "Sony"
      result["model"].should eq "PlayStation 3"
    end
  end

  describe "FeedReader" do
    it "should extract name and version" do
      user_agent = "FeeddlerRSS/2.4 CFNetwork/548.1.4 Darwin/11.0.0"
      detector = DeviceDetector::Parser::FeedReader.new user_agent
      result = detector.call
      result["name"].should eq "Feeddler RSS Reader"
      result["version"].should eq "2.4"
    end
  end

  describe "Library" do
    it "should extract name and version" do
      user_agent = "curl/7.21.0 (i386-redhat-linux-gnu) libcurl/7.21.0 NSS/3.12.10.0 zlib/1.2.5 libidn/1.18 libssh2/1.2.4"
      detector = DeviceDetector::Parser::Library.new user_agent
      result = detector.call
      result["name"].should eq "curl"
      result["version"].should eq "7.21.0"
    end
  end

  describe "Mediaplayer" do
    it "should extract name and version" do
      user_agent = "iTunes/10.2.1 (Macintosh; Intel Mac OS X 10.7) AppleWebKit/534.20.8"
      detector = DeviceDetector::Parser::Mediaplayer.new user_agent
      result = detector.call
      result["name"].should eq "iTunes"
      result["version"].should eq "10.2.1"
    end
  end

  describe "MobileApp" do
    it "should extract name and version" do
      user_agent = "WhatsApp/2.6.4 iPhone_OS/4.3.3 Device/iPhone_4"
      detector = DeviceDetector::Parser::MobileApp.new user_agent
      result = detector.call
      result["name"].should eq("WhatsApp")
      result["version"].should eq("2.6.4")
    end
  end

  describe "Mobile" do
    it "should extract vendor, model and type" do
      user_agent = "Mozilla/5.0 (Linux; Android 7.0; BV6000 Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 YaBrowser/17.1.1.359.00 Mobile Safari/537.36"
      detector = DeviceDetector::Parser::Mobile.new user_agent
      result = detector.call
      result["vendor"].should eq "Blackview"
      result["model"].should eq "BV6000"
      result["type"].should eq "smartphone"
    end

    it "classifies Huawei without treating Honor or other Android devices as Huawei" do
      huawei = "Mozilla/5.0 (Linux; Android 10; ELS-NX9 Build/HUAWEIELS-NX9) AppleWebKit/537.36 Mobile HuaweiBrowser/13.0"
      harmony = "Mozilla/5.0 (Linux; HarmonyOS 4.0; HUAWEI Mate 60 Pro) AppleWebKit/537.36 Mobile"
      honor = "Mozilla/5.0 (Linux; Android 14; FCP-AN10 Build/HONORFCP-AN10) AppleWebKit/537.36 Mobile"
      pixel = "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 Mobile"

      DeviceDetector::Parser::Mobile.prepare_huawei
      DeviceDetector::Parser::Mobile.huawei?(huawei).should be_true
      DeviceDetector::Parser::Mobile.huawei?(harmony).should be_true
      DeviceDetector::Parser::Mobile.huawei?(honor).should be_false
      DeviceDetector::Parser::Mobile.huawei?(pixel).should be_false

      [huawei, harmony, honor, pixel].each do |user_agent|
        detected = DeviceDetector::Parser::Mobile.new(user_agent).call["vendor"] == "Huawei"
        DeviceDetector::Parser::Mobile.huawei?(user_agent).should eq(detected)
      end
    end

    it "matches the full mobile parser for every Huawei index token" do
      parser = DeviceDetector::Parser::Mobile.new("")
      huawei_rule_index = parser.mobile_entries.index { |entry| entry[0] == "Huawei" }
      raise "Huawei mobile rule is missing" unless huawei_rule_index
      huawei_tokens = parser.mobile_index.compact_map do |token, indexes|
        token if indexes.includes?(huawei_rule_index)
      end

      huawei_tokens.each do |token|
        user_agent = "Mozilla/5.0 (Linux; Android 13; #{token} Build/#{token}) AppleWebKit/537.36 Mobile"
        detected = DeviceDetector::Parser::Mobile.new(user_agent).call["vendor"] == "Huawei"
        DeviceDetector::Parser::Mobile.huawei?(user_agent).should eq(detected), token
      end
    end

    it "keeps Huawei decisions stable across parallel workers" do
      cases = {
        "Mozilla/5.0 (Linux; Android 10; ELS-NX9 Build/HUAWEIELS-NX9) AppleWebKit/537.36 Mobile"  => true,
        "Mozilla/5.0 (Linux; Android 14; FCP-AN10 Build/HONORFCP-AN10) AppleWebKit/537.36 Mobile" => false,
        "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 Mobile"                      => false,
      }
      DeviceDetector::Parser::Mobile.prepare_huawei
      context = Fiber::ExecutionContext::Parallel.new("huawei-parser-spec", 4)
      workers = WaitGroup.new(cases.size * 100)
      failures = Atomic(Int32).new(0)

      100.times do
        cases.each do |user_agent, expected|
          context.spawn do
            failures.add(1, :relaxed) unless DeviceDetector::Parser::Mobile.huawei?(user_agent) == expected
          ensure
            workers.done
          end
        end
      end

      workers.wait
      failures.get(:relaxed).should eq(0)
    end
  end

  describe "OS" do
    it "should extract name and version" do
      user_agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.8) Gecko Fedora/1.9.0.8-1.fc10 Kazehakase/0.5.6"
      detector = DeviceDetector::Parser::OS.new user_agent
      result = detector.call
      result["name"].should eq "Fedora"
      result["version"].should eq "1.9.0.8"
    end

    it "should map Windows NT versions" do
      user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
      detector = DeviceDetector::Parser::OS.new user_agent
      result = detector.call
      result["name"].should eq "Windows"
      result["version"].should eq "10"
    end

    it "keeps Android, iOS, HarmonyOS, OpenHarmony, and desktop decisions stable in parallel" do
      DeviceDetector::Parser::OS.prepare
      cases = {
        "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 Mobile"                        => "Android",
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Mobile/15E148" => "iOS",
        "Mozilla/5.0 (Linux; HarmonyOS 4.0; HUAWEI Mate 60 Pro) AppleWebKit/537.36 Mobile"          => "HarmonyOS",
        "Mozilla/5.0 (Linux; OpenHarmony 4.0; HUAWEI Mate 60 Pro) AppleWebKit/537.36 Mobile"        => "OpenHarmony",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0 Safari/537.36"   => "Windows",
      }
      context = Fiber::ExecutionContext::Parallel.new("os-parser-spec", 4)
      workers = WaitGroup.new(cases.size * 20)
      failures = Atomic(Int32).new(0)

      20.times do
        cases.each do |user_agent, expected|
          context.spawn do
            result = DeviceDetector::Parser::OS.new(user_agent).call
            failures.add(1, :relaxed) unless result["name"] == expected
          ensure
            workers.done
          end
        end
      end

      workers.wait
      failures.get(:relaxed).should eq(0)
    end
  end

  describe "PIM" do
    it "should extract name and version" do
      user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Win64; x64; Trident/7.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; InfoPath.3; .NET CLR 1.1.4322; FDM; Tablet PC 2.0; .NET4.0E; Microsoft Outlook 14.0.7113; ms-office; MSOffice 14)"
      detector = DeviceDetector::Parser::PIM.new user_agent
      result = detector.call
      result["name"].should eq "Microsoft Outlook"
      result["version"].should eq "14.0.7113"
    end
  end

  describe "Portable media player" do
    it "should extract vendor and model" do
      user_agent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows CE; IEMobile 6.12; Microsoft ZuneHD 4.3)"
      detector = DeviceDetector::Parser::PortableMediaPlayer.new user_agent
      result = detector.call
      result["vendor"].should eq "Microsoft"
      result["model"].should eq "Zune HD"
    end
  end

  describe "TV" do
    it "should extract vendor and model" do
      user_agent = "Opera/9.80 (Linux armv7l; HbbTV/1.2.1 (; Hisense; SmartTV_2015; V00.01.00a.G0816; HE65M7000UWTSG; )) Presto/2.12.407 Version/12.51 year/2016"
      detector = DeviceDetector::Parser::Television.new user_agent
      result = detector.call
      result["vendor"].should eq "Hisense"
      result["model"].should eq "HE65M7000UWTSG"
    end

    it "should not have vendor or model of tv for browser UA" do
      user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
      detector = DeviceDetector::Parser::Television.new user_agent
      result = detector.call
      result["vendor"].should eq ""
      result["model"].should eq ""
    end
  end

  describe "VendorFragment" do
    it "should extract vendor" do
      user_agent = "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/7.0; SLCC2; .NET CLR 2.0.50727; Media Center PC 6.0; MAAR; Tablet PC 2.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E)"
      detector = DeviceDetector::Parser::VendorFragment.new user_agent
      result = detector.call
      result["vendor"].should eq "Acer"
    end
  end
end
