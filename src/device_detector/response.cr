module DeviceDetector
  class Response
    alias InputStructure = Array(Hash(String, Hash(String, String)))

    def initialize(results : InputStructure)
      @results = results
    end

    # --> Base methods

    def raw
      @results
    end

    # --> Bot

    def bot?
      @results.each do |result|
        return !result.dig?("bot", "name").try &.blank? if result.has_key?("bot")
      end
      false
    end

    def bot_name
      @results.each do |result|
        return result.dig?("bot", "name") if result.has_key?("bot")
      end
    end

    # --> Browser engine

    def browser_engine?
      @results.each do |result|
        return !result.dig?("browser_engine", "name").try &.blank? if result.has_key?("browser_engine")
      end
      false
    end

    def browser_engine_name
      @results.each do |result|
        return result.dig?("browser_engine", "name") if result.has_key?("browser_engine")
      end
    end

    # --> Browser

    def browser?
      @results.each do |result|
        return !result.dig?("browser", "name").try &.blank? if result.has_key?("browser")
      end
      false
    end

    def browser_name
      @results.each do |result|
        return result.dig?("browser", "name") if result.has_key?("browser")
      end
    end

    def browser_version
      @results.each do |result|
        return result.dig?("browser", "version") if result.has_key?("browser")
      end
    end

    # --> Camera

    def camera?
      @results.each do |result|
        return !result.dig?("camera", "model").try &.blank? if result.has_key?("camera")
      end
      false
    end

    def camera_vendor
      @results.each do |result|
        return result.dig?("camera", "vendor") if result.has_key?("camera")
      end
    end

    def camera_model
      @results.each do |result|
        return result.dig?("camera", "model") if result.has_key?("camera")
      end
    end

    # --> Car browser

    def car_browser?
      @results.each do |result|
        return !result.dig?("car_browser", "model").try &.blank? if result.has_key?("car_browser")
      end
      false
    end

    def car_browser_vendor
      @results.each do |result|
        return result.dig?("car_browser", "vendor") if result.has_key?("car_browser")
      end
    end

    def car_browser_model
      @results.each do |result|
        return result.dig?("car_browser", "model") if result.has_key?("car_browser")
      end
    end

    # --> Console

    def console?
      @results.each do |result|
        return true unless result.dig?("console", "model").not_nil!.blank?
      end
      false
    end

    def console_vendor
      @results.each do |result|
        return result.dig?("console", "vendor")
      end
    end

    def console_model
      @results.each do |result|
        return result.dig?("console", "model")
      end
    end

    # --> Feed reader

    def feed_reader?
      @results.each do |result|
        return true unless @results.dig?("feed_reader", "name").not_nil!.blank?
      end
      false
    end

    def feed_reader_name
      @results.each do |result|
        return result.dig?("feed_reader", "name")
      end
    end

    def feed_reader_version
      @results.each do |result|
        return result.dig?("feed_reader", "version")
      end
    end

    # --> Library

    def library?
      @results.each do |result|
        return true unless result.dig?("library", "name").not_nil!.blank?
      end
      false
    end

    def library_name
      @results.each do |result|
        return result.dig?("library", "name")
      end
    end

    def library_version
      @results.each do |result|
        return result.dig?("library", "version")
      end
    end

    # --> Mediaplayer

    def mediaplayer?
      @results.each do |result|
        return true unless result.dig?("mediaplayer", "name").not_nil!.blank?
      end
      false
    end

    def mediaplayer_name
      @results.each do |result|
        return result.dig?("mediaplayer", "name")
      end
    end

    def mediaplayer_version
      @results.each do |result|
        return result.dig?("mediaplayer", "version")
      end
    end

    # --> Mobile app

    def mobile_app?
      @results.each do |result|
        return true unless result.dig?("mobile_app", "name").not_nil!.blank?
      end
      false
    end

    def mobile_app_name
      @results.each do |result|
        return result.dig?("mobile_app", "name")
      end
    end

    def mobile_app_version
      @results.each do |result|
        return result.dig?("mobile_app", "version")
      end
    end

    # --> Mobiles

    def mobile_device?
      @results.each do |result|
        return true unless result.dig?("mobile", "device").not_nil!.blank?
      end
      false
    end

    def mobile_device_vendor
      @results.each do |result|
        return result.dig?("mobile", "vendor")
      end
    end

    def mobile_device_type
      @results.each do |result|
        return result.dig?("mobile", "type")
      end
    end

    def mobile_device_model
      @results.each do |result|
        return result.dig?("mobile", "model")
      end
    end

    # --> OSS

    def os?
      @results.each do |result|
        return true unless result.dig?("oss", "name").not_nil!.blank?
      end
      false
    end

    def os_name
      @results.each do |result|
        return result.dig?("oss", "name")
      end
    end

    def os_version
      @results.each do |result|
        return result.dig?("oss", "version")
      end
    end

    # --> PIM

    def pim?
      @results.each do |result|
        return true unless result.dig?("pim", "name").not_nil!.blank?
      end
      false
    end

    def pim_name
      @results.each do |result|
        return result.dig?("pim", "name")
      end
    end

    def pim_version
      @results.each do |result|
        return result.dig?("pim", "version")
      end
    end

    # --> Portable media player

    def portable_media_player?
      @results.each do |result|
        return true unless result.dig?("portable_media_player", "model").not_nil!.blank?
      end
      false
    end

    def portable_media_player_vendor
      @results.each do |result|
        return result.dig?("portable_media_player", "vendor")
      end
    end

    def portable_media_player_model
      @results.each do |result|
        return result.dig?("portable_media_player", "model")
      end
    end

    # --> TV

    def tv?
      @results.each do |result|
        return true unless result.dig?("tv", "model").not_nil!.blank?
      end
      false
    end

    def tv_vendor
      @results.each do |result|
        return result.dig?("tv", "vendor")
      end
    end

    def tv_model
      @results.each do |result|
        return result.dig?("tv", "model")
      end
    end

    # --> VendorFragment

    def vendorfragment?
      @results.each do |result|
        return true unless result.dig?("vendorfragment", "vendor").not_nil!.blank?
      end
      false
    end

    def vendorfragment_vendor
      @results.each do |result|
        return result.dig?("vendorfragment", "vendor")
      end
    end

  end
end
