require 'spec_helper'

describe "Authy::Response" do
  let(:response) { Authy::Response.new(fake_response) }

  context 'response is valid' do
    let(:fake_response) do
      OpenStruct.new.tap do |struct|
        struct.body = { 'v1' => 'r1','v2' => 42 }.to_json
        struct.status = 200
      end
    end

    it "should parse to json the body" do
      expect(response['v2']).to eq 42
      expect(response.error_msg).to eq "No error"
      expect(response.message).to eq "No error"
      expect(response.ok?).to be_truthy
    end
  end

  context 'response returns a 401 status code' do
    let(:fake_response) do
      OpenStruct.new.tap do |struct|
        struct.status = 401
      end
    end

    it 'response is not ok' do
      expect(response.ok?).to be_falsey
    end
  end

  context 'response returns invalid json' do
    let(:fake_response) do
      OpenStruct.new.tap do |struct|
        struct.body = 'invalid json'
        struct.status = 401
      end
    end

    it "should return the error message" do
      expect(response.error_msg).to eq "invalid json"
    end
  end
end
