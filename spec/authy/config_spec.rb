require 'spec_helper'

describe "Authy" do
  describe "api_key" do
    around do
      Authy.api_key = nil
      ENV["AUTHY_API_KEY"] = nil
    end

    it "should set and read instance variable" do
      Authy.api_key = "foo"
      Authy.api_key.should == "foo"
    end

    it "should fallback to ENV variable" do
      ENV["AUTHY_API_KEY"] = "bar"
      Authy.api_key.should == "bar"
    end
  end

  describe "api_url" do
    around do
      Authy.api_url = nil
    end

    it "should set and read instance variable" do
      Authy.api_url = "https://example.com/"
      Authy.api_url.should == "https://example.com/"
    end

    it "should fallback to default value" do
      Authy.api_url = nil
      Authy.api_url.should be_present
    end
  end
end
