require 'spec_helper'

describe "Authy::API" do
  describe "Registering users" do

    it "should find or create a user" do
      user = Authy::API.register_user(:email => generate_email,
                                      :cellphone => generate_cellphone,
                                      :country_code => 1)
      user.should be_kind_of(Authy::Response)

      user.should be_kind_of(Authy::User)
      user.should_not be_nil
      user.id.should_not be_nil
      user.id.should be_kind_of(Integer)
    end
 
    it "should return the error messages as a hash" do
      user = Authy::API.register_user(:email => generate_email,
                                      :cellphone => "abc-1234",
                                      :country_code => 1)

      user.errors.should be_kind_of(Hash)
      user.errors['cellphone'].should == 'must be a valid cellphone number.'
    end

    it "should allow to override the API key" do
      user = Authy::API.register_user(:email => generate_email,
                                      :cellphone => generate_cellphone,
                                      :country_code => 1,
                                      :api_key => "invalid_api_key")

      user.should_not be_ok
      user.errors['message'].should =~ /invalid api key/i
    end
  end

  describe "verificating tokens" do
    before do
      @user = Authy::API.register_user(:email => generate_email,
                                       :cellphone => generate_cellphone,
                                       :country_code => 1)
      @user.should be_ok
    end

    #it "should validate a given token if the user is not registered when the verification is not forced" do
      #pending "Sandbox api always auto-confirm all users so there's no way check this atm"
      #response = Authy::API.verify(:token => 'invalid_token', :id => @user['id'], :force => false)

      #response.should be_kind_of(Authy::Response)
      #response.ok?.should be_true
    #end

    it "should fail to validate a given token if the user is not registered" do
      response = Authy::API.verify(:token => 'invalid_token', :id => @user['id'])

      response.should be_kind_of(Authy::Response)
      response.ok?.should be_false
      response.errors['token'].should == 'is invalid'
    end

    it "should allow to override the API key" do
      response = Authy::API.verify(:token => 'invalid_token', :id => @user['id'], :api_key => "invalid_api_key")

      response.should_not be_ok
      response.errors['message'].should =~ /invalid api key/i
    end
  end

  describe "Requesting SMS" do
    before do
      @user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
      @user.should be_ok
    end

    it "should request a SMS token" do
      response = Authy::API.request_sms(:id => @user.id)
      response.should be_ok
    end

    it "should allow to override the API key" do
      response = Authy::API.request_sms(:id => @user.id, :api_key => "invalid_api_key")
      response.should_not be_ok
      response.errors['message'].should =~ /invalid api key/i
    end
  end
end
