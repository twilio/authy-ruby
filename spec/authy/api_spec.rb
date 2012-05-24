require 'spec_helper'

describe "Authy::API" do
  it "should find or create a user" do
    user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
    user.should be_kind_of(Authy::Response)

    user.should be_kind_of(Authy::User)
    user.should_not be_nil
    user.id.should_not be_nil
    user.id.should be_kind_of(Integer)
  end

  it "should validate a given token" do
    user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
    response = Authy::API.verify(:token => 'invalid_token', :id => user['id'])

    response.should be_kind_of(Authy::Response)
    response.ok?.should be_true
    response.body.should == 'valid token'
  end

  it "should fail to validate a given token when force=true is given" do
    user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
    response = Authy::API.verify(:token => 'invalid_token', :id => user['id'], :force => true)

    response.should be_kind_of(Authy::Response)
    response.ok?.should be_false
    response.body.should == 'invalid token'
  end

  it "should return the error messages as a hash" do
    user = Authy::API.register_user(:email => generate_email, :cellphone => "abc-1234", :country_code => 1)

    user.errors.should be_kind_of(Hash)
    user.errors['cellphone'].should == ['must be a valid cellphone number.']
  end

  it "should request a SMS token" do
    user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
    user.should be_ok

    response = Authy::API.request_sms(:id => user.id)
    response.should be_ok
  end
end
