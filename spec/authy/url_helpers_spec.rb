require 'spec_helper'

describe "Authy::URL" do
  class Dummy
    include Authy::URL
  end

  describe "escape_for_url" do
    it "should user URI escape" do
      expect(URI).to receive :escape
      Dummy.escape_for_url("that")
    end

    it "should use Regexp" do
      expect(Regexp).to receive(:new).with("[^#{URI::PATTERN::UNRESERVED}]").and_return(/a/)
      Dummy.escape_for_url("that")
    end
  end

  describe "to_param" do
    it "should user HTTP::Message.escape" do
      expect(HTTP::Message).to receive(:escape).exactly(2).times.and_return "basic string"
      Dummy.to_param('key', 'value')
    end

    it "should paramify the left to right" do
      expect(Dummy.to_param('key', 'value')).to eq 'key=value'
    end
  end

  describe "params_from_array" do
    it "should return an array of params" do
      expect(Dummy.params_from_array("da key", ["one", "two"])).to eq([HTTP::Message.escape("da key[]") + "=one", HTTP::Message.escape("da key[]") + "=two"])
    end
  end
end
