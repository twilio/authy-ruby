require 'spec_helper'

describe "Authy::API" do

  describe "request headers" do

    it "contains api key in header" do
      url = "protected/json/foo/2"

      HTTPClient.any_instance.should_receive(:request).twice.with( any_args, hash_including(:header=> { "X-Authy-API-Key" => Authy.api_key }) ) { double(:ok? => true, :body => "", :status => 200) }
      response = Authy::API.get_request(url, {})
      response = Authy::API.post_request(url, {})
    end
  end

  describe "Registering users" do

    it "should find or create a user" do
      user = Authy::API.register_user(
        :email => generate_email,
        :cellphone => generate_cellphone,
        :country_code => 1
      )
      user.should be_kind_of(Authy::Response)

      user.should be_kind_of(Authy::User)
      user.should_not be_nil
      user.id.should_not be_nil
      user.id.should be_kind_of(Integer)
    end

    it "should return the error messages as a hash" do
      user = Authy::API.register_user(
        :email => generate_email,
        :cellphone => "abc-1234",
        :country_code => 1
      )

      user.errors.should be_kind_of(Hash)
      user.errors['cellphone'].should == 'is invalid'
    end

    it "should allow to override the API key" do
      user = Authy::API.register_user(
        :email => generate_email,
        :cellphone => generate_cellphone,
        :country_code => 1,
        :api_key => "invalid_api_key"
      )

      user.should_not be_ok
      user.errors['message'].should =~ /invalid api key/i
    end

  end

  describe "verificating tokens" do
    before do
      @email = generate_email
      @cellphone = generate_cellphone
      @user = Authy::API.register_user(:email => @email,
                                       :cellphone => @cellphone,
                                       :country_code => 1)
      @user.should be_ok
    end

    it "should fail to validate a given token if the user is not registered" do
      response = Authy::API.verify(:token => 'invalid_token', :id => @user.id)

      response.should be_kind_of(Authy::Response)
      response.ok?.should be_falsey
      response.errors['message'].should == 'Token format is invalid'
    end

    it "should allow to override the API key" do
      response = Authy::API.verify(:token => '123456', :id => @user['id'], :api_key => "invalid_api_key")

      response.should_not be_ok
      response.errors['message'].should =~ /invalid api key/i
    end

    it "should escape the params" do
      expect {
        Authy::API.verify(:token => '[=#%@$&#(!@);.,', :id => @user['id'])
      }.to_not raise_error
    end

    it "should escape the params if have white spaces" do
      expect {
        Authy::API.verify(:token => "token with space", :id => @user['id'])
      }.to_not raise_error
    end

    it "should fail if a param is missing" do
      response = Authy::API.verify(:id => @user['id'])
      response.should be_kind_of(Authy::Response)
      response.should_not be_ok
      response["message"] =~ /Token format is invalid/
    end

    it 'fails when token format is invalid' do
      response = Authy::API.verify(:token => '0000', :id => @user.id)

      expect(response.ok?).to be_falsey
      response.should be_kind_of(Authy::Response)
      expect(response.errors['message']).to eq 'Token format is invalid'
    end
  end

  ["sms", "phone_call"].each do |kind|
    title = kind.upcase
    describe "Requesting #{title}" do
      before do
        @user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
        @user.should be_ok
      end

      it "should request a #{title} token" do
        uri_param = kind == "phone_call" ? "call" : kind
        url = "#{Authy.api_uri}/protected/json/#{uri_param}/#{Authy::API.escape_for_url(@user.id)}"
        HTTPClient.any_instance.should_receive(:request).with(:get, url, {:query=>{:api_key=> Authy.api_key}, :header=>{ "X-Authy-API-Key" => Authy.api_key }, :follow_redirect=>nil}) { double(:ok? => true, :body => "", :status => 200) }
        response = Authy::API.send("request_#{kind}", :id => @user.id)
        response.should be_ok
      end

      it "should allow to override the API key" do
        response = Authy::API.send("request_#{kind}", :id => @user.id, :api_key => "invalid_api_key")
        response.should_not be_ok
        response.errors['message'].should =~ /invalid api key/i
      end

      it "should request a #{title} token using custom actions" do
        response = Authy::API.send("request_#{kind}", id: @user.id, action: "custom action?", action_message: "Action message $%^?@#")
        response.should be_ok
      end

      context "user doesn't exist" do
        it "should not be ok" do
          response = Authy::API.send("request_#{kind}", :id => "tony")
          response.errors['message'].should == "User not found."
          response.should_not be_ok
        end
      end
    end
  end

  describe "delete users" do
    context "user doesn't exist" do
      it "should not be ok" do
        response = Authy::API.delete_user(:id => "tony")
        response.errors['message'].should == "User not found."
        response.should_not be_ok
      end
    end

    context "user exists" do
      before do
        @user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
        @user.should be_ok
      end

      it "should be ok" do
        response = Authy::API.delete_user(:id => @user.id)
        response.message.should == "User was added to remove."
        response.should be_ok
      end
    end
  end

  describe "user status" do
    context "user doesn't exist" do
      it "should not be ok" do
        response = Authy::API.user_status(:id => "tony")
        response.errors["message"].should == "User not found."
        response.should_not be_ok
      end
    end

    context "user exists" do
      before do
        @user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
        @user.should be_ok
      end

      it "should be ok" do
        response = Authy::API.user_status(:id => @user.id)
        response.status.should be_kind_of(Hash)
        response.should be_ok
      end
    end
  end

  describe "blank params" do
    before do
      @user = Authy::API.register_user(:email => generate_email, :cellphone => generate_cellphone, :country_code => 1)
      @user.should be_ok
    end

    [:request_sms, :request_phone_call, :delete_user].each do |method|
      it "should return a proper response with the errors for #{method}" do
        response = Authy::API.send(method, :id => nil)
        response.should_not be_ok
        response.message.should == "user_id is blank."
      end
    end

    it "should return a prope response with the errors for verify" do
      response = Authy::API.verify({})
      expect(response).to_not be_ok
      expect(response.message).to eq "Token format is invalid"
    end
  end

  describe '.token_is_safe?' do
    it 'checks minimum token size' do
      expect(Authy::API.send(:token_is_safe?, '1')).to be false
    end

    it 'checks valid characters' do
      expect(Authy::API.send(:token_is_safe?, '123456')).to be true
      expect(Authy::API.send(:token_is_safe?, '123456a')).to be false
    end

    it 'checks maximum token size' do
      expect(Authy::API.send(:token_is_safe?, '123456789098')).to be true
      expect(Authy::API.send(:token_is_safe?, '1234567890987')).to be false
    end
  end
end
