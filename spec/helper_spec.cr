require "./spec_helper"

describe "Helper" do
  it "should detect capture group" do
    DeviceDetector::Helper.capture_groups?("$1").should be_true
  end

  it "should fill capture groups" do
    user_agent = "Browser/123.45"
    DeviceDetector::Helper.fill_groups("version $1", "Browser/(\\d+\\.\\d+)", user_agent).should eq("version 123.45")
  end
end
