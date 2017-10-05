require 'spec_helper'

describe "Authy::Response" do
  before :each do
    @fake_response = OpenStruct.new
    @fake_response.body = { 'v1' => 'r1','v2' => 42 }.to_json
    @fake_response.status = 200

    @response = Authy::Response.new(@fake_response)
  end

  it "should parse to json the body" do
    expect(@response['v2']).to eq 42
  end

  it "should be ok if the return code is 200" do
    expect(@response.ok?).to be_truthy

    @fake_response.status = 401
    @response = Authy::Response.new(@fake_response)
    expect(@response.ok?).to be_falsey
  end

  it "should return the error message" do
    expect(@response.error_msg).to eq "No error"

    @fake_response.body = 'invalid json'
    @fake_response.status = 401
    @response = Authy::Response.new(@fake_response)

    expect(@response.error_msg).to eq "invalid json"
  end
end
