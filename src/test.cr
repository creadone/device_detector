require "./device_detector"

bot = "Googlebot/2.1 (+http://www.google.com/bot.html)"

response = DeviceDetector::Detector.new(bot).call

pp response.feed_reader_name
