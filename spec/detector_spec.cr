require "./spec_helper"

describe "Detector" do
  it "should return expected response class" do
    user_agent = "Mozilla/5.0 (Windows NT 6.4; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.143 Safari/537.36 Edge/12.0"
    d = DeviceDetector::Detector.new user_agent
    d.call.should be_a(DeviceDetector::Response)
  end
end
