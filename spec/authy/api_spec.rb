require 'spec_helper'

describe "Authy::API" do
  it "should get a valid moving factor" do
    mf = Authy::API.moving_factor
    mf.should be_kind_of(Authy::Response)

    mf['moving_factor'].should_not be_nil
    mf['moving_factor'].should be_kind_of(String)
    mf['moving_factor'].length.should == 9
  end

  it "should find or create a user" do
    user = Authy::API.register_user(:user => {:email => generate_email})
    user.should be_kind_of(Authy::Response)

    user.should be_kind_of(Authy::User)
    user.should_not be_nil
    user.id.should_not be_nil
    user.id.should be_kind_of(Integer)
  end

  it "should validate a given token" do
    user = Authy::API.register_user(:user => {:email => generate_email})
    response = Authy::API.verify(:token => 'invalid_token', :id => user['id'])

    response.should be_kind_of(Authy::Response)
    response.ok?.should be_false
    response.body.should == 'invalid token'
  end
end
