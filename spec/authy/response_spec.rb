require 'spec_helper'

describe "Authy::Response" do
  before :each do
    @fake_response = OpenStruct.new
    @fake_response.body = {'v1' => 'r1','v2' => 42}.to_json
    @fake_response.status = 200

    @response = Authy::Response.new(@fake_response)
  end

  it "should parse to json the body" do
    @response['v2'].should == 42
  end

  it "should be ok if the return code is 200" do
    @response.ok?.should be_true

    @fake_response.status = 401
    @response = Authy::Response.new(@fake_response)
    @response.ok?.should be_false
  end

  it "should return the error message" do
    @response.error_msg.should == "No error"

    @fake_response.body = 'invalid json'
    @fake_response.status = 401
    @response = Authy::Response.new(@fake_response)

    @response.error_msg.should == "invalid json"
  end
end
