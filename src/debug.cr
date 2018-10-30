require "./device_detector"

bot = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
ipad = "Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X; en-us) AppleWebKit/534.46 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53"

response = DeviceDetector::Detector.new(ipad).call

pp response.raw

pp response.browser?
pp response.browser_name
pp response.browser_version

pp response.browser_engine?
pp response.browser_engine_name

# pp response.bot?
