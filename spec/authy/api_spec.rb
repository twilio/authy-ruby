require 'spec_helper'

describe "Authy::API" do
  describe "request headers" do
    it "contains api key in header" do
      expect_any_instance_of(HTTPClient).to receive(:request).twice.with( any_args, hash_including(header: { "X-Authy-API-Key" => Authy.api_key }) ) { double(ok?: true, body: "", status: 200) }

      url = "protected/json/foo/2"
      Authy::API.get_request(url, {})
      Authy::API.post_request(url, {})
    end
  end

  describe "Registering users" do
    it "should find or create a user" do
      user = Authy::API.register_user(
        email: generate_email,
        cellphone: generate_cellphone,
        country_code: 1
      )

      expect(user).to be_kind_of(Authy::Response)
      expect(user).to be_kind_of(Authy::User)
      expect(user).to_not be_nil
      expect(user.id).to_not be_nil
      expect(user.id).to be_kind_of(Integer)
    end

    it "should return the error messages as a hash" do
      user = Authy::API.register_user(
        email: generate_email,
        cellphone: "abc-1234",
        country_code: 1
      )

      expect(user.errors).to be_kind_of(Hash)
      expect(user.errors['cellphone']).to include 'is invalid'
    end

    it "should allow to override the API key" do
      user = Authy::API.register_user(
        email: generate_email,
        cellphone: generate_cellphone,
        country_code: 1,
        api_key: "invalid_api_key"
      )

      expect(user).to_not be_ok
      expect(user.errors['message']).to match(/invalid api key/i)
    end

    it "should allow overriding send_install_link_via_sms default" do
      user = Authy::API.register_user(
        email: generate_email,
        cellphone: generate_cellphone,
        country_code: 1,
        send_install_link_via_sms: false # Default is true. See http://docs.authy.com/totp.html#totp-api
      )

      expect(user).to be_kind_of(Authy::Response)
      expect(user).to be_kind_of(Authy::User)
      expect(user).to_not be_nil
      expect(user.id).to_not be_nil
      expect(user.id).to be_kind_of(Integer)
    end

  end

  describe "verificating tokens" do
    before do
      @email = generate_email
      @cellphone = generate_cellphone
      @user = Authy::API.register_user(
        email: @email,
        cellphone: @cellphone,
        country_code: 1
      )
      expect(@user).to be_ok
    end

    it "should fail to validate a given token if the user is not registered" do
      response = Authy::API.verify(token: 'invalid_token', id: @user.id)

      expect(response).to be_kind_of(Authy::Response)
      expect(response.ok?).to be_falsey
      expect(response.errors['message']).to include 'Token format is invalid'
    end

    it "should allow to override the API key" do
      response = Authy::API.verify(token: '123456', id: @user['id'], api_key: "invalid_api_key")

      expect(response).to_not be_ok
      expect(response.errors['message']).to match(/invalid api key/i)
    end

    it "should escape the params" do
      expect do
        Authy::API.verify(token: '[=#%@$&#(!@);.,', id: @user['id'])
      end.to_not raise_error
    end

    it "should escape the params if have white spaces" do
      expect do
        Authy::API.verify(token: "token with space", id: @user['id'])
      end.to_not raise_error
    end

    it "should fail if a param is missing" do
      response = Authy::API.verify(id: @user['id'])
      expect(response).to be_kind_of(Authy::Response)
      expect(response).to_not be_ok
      expect(response["message"]).to include('Token format is invalid')
    end

    it 'fails when token format is invalid' do
      response = Authy::API.verify(token: '0000', id: @user.id)

      expect(response.ok?).to be_falsey
      expect(response).to be_kind_of(Authy::Response)
      expect(response.errors['message']).to eq 'Token format is invalid'
    end
  end

  ["sms", "phone_call"].each do |kind|
    title = kind.upcase
    describe "Requesting #{title}" do
      before do
        @user = Authy::API.register_user(email: generate_email, cellphone: generate_cellphone, country_code: 1)
        expect(@user).to be_ok
      end

      it "should request a #{title} token" do
        uri_param = kind == "phone_call" ? "call" : kind
        url = "#{Authy.api_uri}/protected/json/#{uri_param}/#{Authy::API.escape_for_url(@user.id)}"
        expect_any_instance_of(HTTPClient).to receive(:request).with(:get, url, {query:{}, header:{ "X-Authy-API-Key" => Authy.api_key }, follow_redirect:nil}) { double(ok?: true, body: "", status: 200) }
        response = Authy::API.send("request_#{kind}", id: @user.id)
        expect(response).to be_ok
      end

      it "should allow to override the API key" do
        response = Authy::API.send("request_#{kind}", id: @user.id, api_key: "invalid_api_key")
        expect(response).to_not be_ok
        expect(response.errors['message']).to match(/invalid api key/i)
      end

      it "should request a #{title} token using custom actions" do
        response = Authy::API.send("request_#{kind}", id: @user.id, action: "custom action?", action_message: "Action message $%^?@#")
        expect(response).to be_ok
      end

      context "user doesn't exist" do
        it "should not be ok" do
          response = Authy::API.send("request_#{kind}", id: "tony")
          expect(response.errors['message']).to eq "User not found."
          expect(response).to_not be_ok
        end
      end
    end
  end

  describe "delete users" do
    context "user doesn't exist" do
      it "should not be ok" do
        response = Authy::API.delete_user(id: "tony")
        expect(response.errors['message']).to eq "User not found."
        expect(response).to_not be_ok
      end
    end

    context "user exists" do
      before do
        @user = Authy::API.register_user(email: generate_email, cellphone: generate_cellphone, country_code: 1)
        expect(@user).to be_ok
      end

      it "should be ok" do
        response = Authy::API.delete_user(id: @user.id)
        expect(response.message).to eq "User was added to remove."
        expect(response).to be_ok
      end
    end
  end

  describe "user status" do
    context "user doesn't exist" do
      it "should not be ok" do
        response = Authy::API.user_status(id: "tony")
        expect(response.errors["message"]).to eq "User not found."
        expect(response).to_not be_ok
      end
    end

    context "user exists" do
      before do
        @user = Authy::API.register_user(email: generate_email, cellphone: generate_cellphone, country_code: 1)
        expect(@user).to be_ok
      end

      it "should be ok" do
        response = Authy::API.user_status(id: @user.id)
        expect(response.status).to be_kind_of(Hash)
        expect(response).to be_ok
      end
    end
  end

  describe "blank params" do
    before do
      @user = Authy::API.register_user(email: generate_email, cellphone: generate_cellphone, country_code: 1)
      expect(@user).to be_ok
    end

    [:request_sms, :request_phone_call, :delete_user].each do |method|
      it "should return a proper response with the errors for #{method}" do
        response = Authy::API.send(method, id: nil)
        expect(response).to_not be_ok
        expect(response.message).to eq "user_id is blank."
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
