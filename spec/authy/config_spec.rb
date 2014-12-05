require 'spec_helper'

describe "Authy" do
  describe "api_key" do
    before(:each) do
      @default_api_key = Authy.api_key
      Authy.api_key = nil
      ENV["AUTHY_API_KEY"] = nil
    end

    after(:each) do
      Authy.api_key = @default_api_key
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
    before(:each) do
      @default_api_url = Authy.api_url
      Authy.api_url = nil
    end

    after(:each) do
      Authy.api_url = @default_api_url
    end

    it "should set and read instance variable" do
      Authy.api_url = "https://example.com/"
      Authy.api_url.should == "https://example.com/"
    end

    it "should fallback to default value" do
      Authy.api_url = nil
      Authy.api_url.should == "https://api.authy.com"
    end
  end
end
