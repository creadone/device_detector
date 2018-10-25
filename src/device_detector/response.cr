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
        return true unless result.dig?("bot", "name").empty?
      end
      false
    end

    def bot_name
      @results.each do |result|
        return result.dig?("bot", "name")
      end
    end

    # --> Browser engine

    def browser_engine?
      @results.each do |result|
        return true unless result.dig?("browser_engine", "name").empty?
      end
      false
    end

    def browser_engine_name
      @results.each do |result|
        return result.dig?("browser_engine", "name")
      end
    end

    # --> Browser

    def browser?
      @results.each do |result|
        return true unless result.dig?("browser", "name").empty?
      end
      false
    end

    def browser_name
      @results.each do |result|
        return result.dig?["browser"]["name"]?
      end
    end

    def browser_version
      @results.each do |result|
        return result["browser"]["version"]?
      end
    end

    # --> Camera

    def camera?
      @results.each do |result|
        return true unless result["camera"]["model"].empty?
      end
      false
    end

    def camera_vendor
      @results.each do |result|
        return result["camera"]["vendor"]?
      end
    end

    def camera_model
      @results.each do |result|
        return result["camera"]["device"]?
      end
    end

    # --> Car browser

    def car_browser?
      @results.each do |result|
        return true unless result["car_browser"]["model"].empty?
      end
      false
    end

    def car_browser_vendor
      @results.each do |result|
        return result["car_browser"]["vendor"]?
      end
    end

    def car_browser_model
      @results.each do |result|
        return result["car_browser"]["model"]?
      end
    end

    # --> Console

    def console?
      @results.each do |result|
        return true unless result["console"]["model"].empty?
      end
      false
    end

    def console_vendor
      @results.each do |result|
        return result["console"]["vendor"]?
      end
    end

    def console_model
      @results.each do |result|
        return result["console"]["model"]?
      end
    end

    # --> Feed reader

    def feed_reader?
      @results.each do |result|
        return true unless result.dig?("feed_reader", "name").empty?
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
        return result["feed_reader"]["version"]?
      end
    end

    # --> Library

    def library?
      @results.each do |result|
        return true if result.has_key?("library")
      end
      false
    end

    def library_name
      @results.each do |result|
        return result["library"]["name"] if result.has_key?("library")
      end
    end

    def library_version
      @results.each do |result|
        return result["library"]["version"] if result.has_key?("library")
      end
    end

    # --> Mediaplayer

    def mediaplayer?
      @results.each do |result|
        return true if result.has_key?("mediaplayer")
      end
      false
    end

    def mediaplayer_name
      @results.each do |result|
        return result["mediaplayer"]["name"] if result.has_key?("mediaplayer")
      end
    end

    def mediaplayer_version
      @results.each do |result|
        return result["mediaplayer"]["version"] if result.has_key?("mediaplayer")
      end
    end

    # --> Mobile app

    def mobile_app?
      @results.each do |result|
        return true if result.has_key?("mobile_app")
      end
      false
    end

    def mobile_app_name
      @results.each do |result|
        return result["mobile_app"]["name"] if result.has_key?("mobile_app")
      end
    end

    def mobile_app_version
      @results.each do |result|
        return result["mobile_app"]["version"] if result.has_key?("mobile_app")
      end
    end

    # --> Mobiles

    def mobile_device?
      @results.each do |result|
        return true if result.has_key?("mobile")
      end
      false
    end

    def mobile_device_vendor
      @results.each do |result|
        return result["mobile"]["vendor"] if result.has_key?("mobile")
      end
    end

    def mobile_device_type
      @results.each do |result|
        return result["mobile"]["type"] if result.has_key?("mobile")
      end
    end

    def mobile_device_model
      @results.each do |result|
        return result["mobile"]["model"] if result.has_key?("mobile")
      end
    end

    # --> OSS

    def os?
      @results.each do |result|
        return true if result.has_key?("oss")
      end
      false
    end

    def os_name
      @results.each do |result|
        return result["oss"]["name"] if result.has_key?("oss")
      end
    end

    def os_version
      @results.each do |result|
        return result["oss"]["version"] if result.has_key?("oss")
      end
    end

    # --> PIM

    def pim?
      @results.each do |result|
        return true if result.has_key?("pim")
      end
      false
    end

    def pim_name
      @results.each do |result|
        return result["pim"]["name"] if result.has_key?("pim")
      end
    end

    def pim_version
      @results.each do |result|
        return result["pim"]["version"] if result.has_key?("pim")
      end
    end

    # --> Portable media player

    def portable_media_player?
      @results.each do |result|
        return true if result.has_key?("portable_media_player")
      end
      false
    end

    def portable_media_player_vendor
      @results.each do |result|
        return result["portable_media_player"]["vendor"] if result.has_key?("portable_media_player")
      end
    end

    def portable_media_player_model
      @results.each do |result|
        return result["portable_media_player"]["model"] if result.has_key?("portable_media_player")
      end
    end

    # --> TV

    def tv?
      @results.each do |result|
        return true if result.has_key?("tv")
      end
      false
    end

    def tv_vendor
      @results.each do |result|
        return result["tv"]["vendor"] if result.has_key?("tv")
      end
    end

    def tv_model
      @results.each do |result|
        return result["tv"]["model"] if result.has_key?("tv")
      end
    end

    # --> VendorFragment

    def vendorfragment?
      @results.each do |result|
        return true if result.has_key?("vendorfragment")
      end
      false
    end

    def vendorfragment_vendor
      @results.each do |result|
        return result["vendorfragment"]["vendor"] if result.has_key?("vendorfragment")
      end
    end

  end
end
