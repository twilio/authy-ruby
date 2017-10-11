require 'spec_helper'

describe 'Authy' do
  describe 'api_key' do
    before do
      @default_api_key = Authy.api_key
      Authy.api_key = nil
      ENV['AUTHY_API_KEY'] = nil
    end

    after do
      Authy.api_key = @default_api_key
    end


    it "should set and read instance variable" do
      Authy.api_key = 'foo'
      expect(Authy.api_key).to eq 'foo'
    end

    it "should fallback to ENV variable" do
      ENV['AUTHY_API_KEY'] = 'bar'
      expect(Authy.api_key).to eq 'bar'
    end
  end

  describe "api_url" do
    before do
      @default_api_url = Authy.api_url
      Authy.api_url = nil
    end

    after do
      Authy.api_url = @default_api_url
    end

    it "should set and read instance variable" do
      Authy.api_url = 'https://example.com/'
      expect(Authy.api_url).to eq 'https://example.com/'
    end

    it "should fallback to default value" do
      Authy.api_url = nil
      expect(Authy.api_url).to eq 'https://api.authy.com'
    end
  end
end
