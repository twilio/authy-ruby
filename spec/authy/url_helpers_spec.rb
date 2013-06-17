require 'spec_helper'

describe "Authy::URL" do
  class Dummy
    include Authy::URL
  end

  describe "escape_for_url" do
    it "should user URI escape" do
      URI.should_receive :escape
      Dummy.escape_for_url("that")
    end

    it "should use Regexp" do
      Regexp.should_receive(:new).with("[^#{URI::PATTERN::UNRESERVED}]").and_return(/a/)
      Dummy.escape_for_url("that")
    end
  end

  describe "to_param" do
    it "should user HTTP::Message.escape" do
      HTTP::Message.should_receive(:escape).exactly(2).times.and_return "basic string"
      Dummy.to_param('key', 'value')
    end

    it "should paramify the left to right" do
      Dummy.to_param('key', 'value').should == 'key=value'
    end
  end

  describe "params_from_array" do
    it "should return an array of params" do
      Dummy.params_from_array("da key", ["one", "two"]).should == [HTTP::Message.escape("da key[]") + "=one", HTTP::Message.escape("da key[]") + "=two"]
    end
  end
end
