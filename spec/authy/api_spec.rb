require "spec_helper"

class Utils
  include Authy::URL
end

describe "Authy::API" do
  let(:headers) { { "X-Authy-API-Key" => Authy.api_key, "User-Agent" => "AuthyRuby/#{Authy::VERSION} (#{RUBY_PLATFORM}, Ruby #{RUBY_VERSION})" } }
  let(:user_id) { 81547 }
  let(:invalid_api_key) { "invalid_api_key" }

  describe "request headers" do
    it "contains api key and user agent in header" do
      expect_any_instance_of(HTTPClient).to receive(:request).twice.with(any_args, hash_including(header: headers)) { double(ok?: true, body: "", status: 200) }

      url = "protected/json/foo/2"
      Authy::API.get_request(url, {})
      Authy::API.post_request(url, {})
    end
  end

  describe "Registering users" do
    let(:register_user_url) { "#{Authy.api_uri}/protected/json/users/new" }

    it "should register a user successfully" do
      user_attributes = {
        email: generate_email,
        cellphone: generate_cellphone,
        country_code: 1
      }
      response_json = {
        "message" => "User created successfully.",
        "user" => { "id" => user_id },
        "success" => true
      }.to_json
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, register_user_url, {
          :body => Utils.escape_query(
            :user => user_attributes,
            :send_install_link_via_sms => true
          ),
          :header => headers
        })
        .and_return(double(:status => 200, :body => response_json))

      user = Authy::API.register_user(user_attributes)

      expect(user).to be_kind_of(Authy::Response)
      expect(user).to be_kind_of(Authy::User)
      expect(user).to_not be_nil
      expect(user.id).to_not be_nil
      expect(user.id).to be(user_id)
    end

    it "should return the error messages as a hash" do
      user_attributes = {
        email: generate_email,
        cellphone: "abc-1234",
        country_code: 1
      }
      response_json = {
        "cellphone" => "is invalid",
        "message" => "User was not valid",
        "success" => false,
        "errors" => {
          "cellphone" => "is invalid",
          "message" => "User was not valid"
        },
        "error_code" => "60027"
      }.to_json

      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, register_user_url, {
          :body => Utils.escape_query(
            :user => user_attributes,
            :send_install_link_via_sms => true
          ),
          :header => headers
        })
        .and_return(double(:status => 400, :body => response_json))

      user = Authy::API.register_user(user_attributes)

      expect(user.errors).to be_kind_of(Hash)
      expect(user.errors["cellphone"]).to include "is invalid"
    end

    it "should allow to override the API key" do
      response_json = {
        "error_code" => "60001",
        "message" => "Invalid API key",
        "errors" => {"message" => "Invalid API key"},
        "success" => false
      }.to_json
      user_attributes = {
        email: generate_email,
        cellphone: generate_cellphone,
        country_code: 1,
        api_key: invalid_api_key
      }

      headers["X-Authy-API-Key"] = invalid_api_key

      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, register_user_url, {
          :body => Utils.escape_query(
            :user => user_attributes.reject { |k,v| k === :api_key },
            :send_install_link_via_sms => true
          ),
          :header => headers
        })
        .and_return(double(:status => 401, :body => response_json))

      user = Authy::API.register_user(user_attributes)

      expect(user).to_not be_ok
      expect(user.errors["message"]).to match(/invalid api key/i)
    end

    it "should allow overriding send_install_link_via_sms default" do
      response_json = {
        "message" => "User created successfully.",
        "user" => { "id" => user_id },
        "success" => true
      }.to_json
      user_attributes = {
        email: generate_email,
        cellphone: generate_cellphone,
        country_code: 1,
        send_install_link_via_sms: false
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, register_user_url, {
          :body => Utils.escape_query(
            :user => user_attributes.reject { |k,v| k === :send_install_link_via_sms },
            :send_install_link_via_sms => false
          ),
          :header => headers
        })
        .and_return(double(:status => 200, :body => response_json))

        user = Authy::API.register_user(user_attributes)

      expect(user).to be_kind_of(Authy::Response)
      expect(user).to be_kind_of(Authy::User)
      expect(user).to_not be_nil
      expect(user.id).to_not be_nil
      expect(user.id).to be_kind_of(Integer)
    end
  end

  describe "verifying tokens" do
    let(:token) { "123456" }
    let(:verify_url) { "#{Authy.api_uri}/protected/json/verify/#{token}/#{user_id}" }

    it "should fail to validate a given token if the token is the wrong format" do
      expect(Authy::API.http_client).to receive(:request).never
      response = Authy::API.verify(token: "invalid_token", id: user_id)

      expect(response).to be_kind_of(Authy::Response)
      expect(response.ok?).to be_falsey
      expect(response.errors["message"]).to include "Token format is invalid"
    end

    it "should allow to override the API key" do
      response_json = {
        "error_code" => "60001",
        "message" => "Invalid API key",
        "errors" => {"message" => "Invalid API key"},
        "success" => false
      }.to_json
      headers["X-Authy-API-Key"] = invalid_api_key
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, verify_url, {
          :query => { :force => true },
          :header => headers,
          :follow_redirect => nil
        })
        .and_return(double(:status => 401, :body => response_json))

      response = Authy::API.verify(token: "123456", id: user_id, api_key: invalid_api_key)

      expect(response).to_not be_ok
      expect(response.errors["message"]).to match(/invalid api key/i)
    end

    it "should escape the params" do
      expect(Authy::API.http_client).to receive(:request).never
      expect do
        Authy::API.verify(token: "[=#%@$&#(!@);.,", id: user_id)
      end.to_not raise_error
    end

    it "should escape the params if have white spaces" do
      expect(Authy::API.http_client).to receive(:request).never
      expect do
        Authy::API.verify(token: "token with space", id: user_id)
      end.to_not raise_error
    end

    it "should fail if a param is missing" do
      expect(Authy::API.http_client).to receive(:request).never
      response = Authy::API.verify(id: user_id)
      expect(response).to be_kind_of(Authy::Response)
      expect(response).to_not be_ok
      expect(response["message"]).to include("Token format is invalid")
    end

    it "fails when token format is invalid" do
      expect(Authy::API.http_client).to receive(:request).never
      response = Authy::API.verify(token: "0000", id: user_id)

      expect(response.ok?).to be_falsey
      expect(response).to be_kind_of(Authy::Response)
      expect(response.errors["message"]).to eq "Token format is invalid"
    end
  end

  describe "requesting qr code for other authenticator apps" do
    it "should request qrcode" do
      url = "#{Authy.api_uri}/protected/json/users/#{user_id}/secret"
      expect_any_instance_of(HTTPClient).to receive(:request).with(:post, url, body: "qr_size=300&label=example+app+name", header: { "X-Authy-API-Key" => Authy.api_key, "User-Agent" => "AuthyRuby/#{Authy::VERSION} (#{RUBY_PLATFORM}, Ruby #{RUBY_VERSION})" }) { double(ok?: true, body: "", status: 200) }
      response = Authy::API.send("request_qr_code", id: user_id, qr_size: 300, qr_label: "example app name")
      expect(response).to be_ok
    end

    context "user id is not a number" do
      it "should not be ok" do
        expect(Authy::API.http_client).to receive(:request).never
        response = Authy::API.send("request_qr_code", id: "tony")
        expect(response.errors["message"]).to eq "User id is invalid"
        expect(response).to_not be_ok
      end
    end

    context "qr size is not a number" do
      it "should return the right error" do
        expect(Authy::API.http_client).to receive(:request).never
        response = Authy::API.send("request_qr_code", id: user_id, qr_size: "notanumber")
        expect(response.errors["message"]).to eq "Qr image size is invalid"
        expect(response).to_not be_ok
      end
    end
  end

  ["sms", "phone_call"].each do |kind|
    title = kind.upcase
    describe "Requesting #{title}" do
      let(:uri_param) { kind == "phone_call" ? "call" : kind }
      let(:url) { "#{Authy.api_uri}/protected/json/#{uri_param}/#{user_id}" }

      it "should request a #{title} token" do
        expect_any_instance_of(HTTPClient).to receive(:request).with(:get, url, { query: {}, header: { "X-Authy-API-Key" => Authy.api_key, "User-Agent" => "AuthyRuby/#{Authy::VERSION} (#{RUBY_PLATFORM}, Ruby #{RUBY_VERSION})" }, follow_redirect: nil }) { double(ok?: true, body: "", status: 200) }
        response = Authy::API.send("request_#{kind}", id: user_id)
        expect(response).to be_ok
      end

      it "should allow to override the API key" do
        response_json = {
          "error_code" => "60001",
          "message" => "Invalid API key",
          "errors" => {"message" => "Invalid API key"},
          "success" => false
        }.to_json
        headers["X-Authy-API-Key"] = invalid_api_key
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, url, {
          :header => headers,
          :query => {},
          :follow_redirect => nil
        })
        .and_return(double(:status => 401, :body => response_json))
        response = Authy::API.send("request_#{kind}", id: user_id, api_key: invalid_api_key)
        expect(response).to_not be_ok
        expect(response.errors["message"]).to match(/invalid api key/i)
      end

      it "should request a #{title} token using custom actions" do
        response_json = {
          :success => true
        }.to_json
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, url, {
          :header => headers,
          :query => {
            :action => "custom action?",
            :action_message => "Action message $%^?@#"
          },
          :follow_redirect => nil
        })
        .and_return(double(:status => 200, :body => response_json))
        response = Authy::API.send("request_#{kind}", id: user_id, action: "custom action?", action_message: "Action message $%^?@#")
        expect(response).to be_ok
      end

      context "user doesn't exist" do
        it "should not be ok" do
          url = "#{Authy.api_uri}/protected/json/#{uri_param}/tony"
          response_json = {
            "message" => "User not found.",
            "success" => false,
            "errors" => { "message" => "User not found." },
            "error_code" => "60026"
          }.to_json
          expect(Authy::API.http_client).to receive(:request)
          .once
          .with(:get, url, {
            :header => headers,
            :query => { },
            :follow_redirect => nil
          })
          .and_return(double(:status => 404, :body => response_json))
          response = Authy::API.send("request_#{kind}", id: "tony")
          expect(response.errors["message"]).to eq "User not found."
          expect(response).to_not be_ok
        end
      end
    end
  end

  describe "Requesting email" do
    it "should request an email token" do
      response_json = {
        "success" => true,
        "message" => "Email token was sent",
        "email" => "recipient@foo.com",
        "email_id" => "EMa364aa751cc280d8c22772307e2c5760"
      }.to_json
      url = "#{Authy.api_uri}/protected/json/email/#{user_id}"

      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, { body: "", header: headers })
        .and_return(double(ok?: true, body: response_json, status: 200))
      response = Authy::API.request_email(id: user_id)
      expect(response).to be_ok
    end

    context "user doesn't exist" do
      it "should not be ok" do
        url = "#{Authy.api_uri}/protected/json/email/tony"
        response_json = {
          "message" => "User not found.",
          "success" => false,
          "errors" => {
            "message" => "User not found."
          },
          "error_code" => "60026"
        }.to_json
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, {
          :header => headers,
          :body => ""
        })
        .and_return(double(:status => 404, :body => response_json))
        response = Authy::API.request_email(id: "tony")
        expect(response.errors['message']).to eq "User not found."
        expect(response).to_not be_ok
      end
    end
  end

  describe "update user email" do
    context "user doesn't exist" do
      it "should not be ok" do
        url = "#{Authy.api_uri}/protected/json/users/tony/update"
        response_json = {
          "message" => "User not found.",
          "success" => false,
          "errors" => {
            "message" => "User not found."
          },
          "error_code" => "60026"
        }.to_json
        new_email = generate_email
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, {
          :header => headers,
          :body => Utils.escape_query(:email => new_email)
        })
        .and_return(double(:status => 404, :body => response_json))

        response = Authy::API.update_user(id: "tony", email: new_email)
        expect(response.errors['message']).to eq "User not found."
        expect(response).to_not be_ok
      end
    end

    context "user exists" do
      it "should be ok" do
        response_json = {
          "message" => "User was updated successfully",
          "success" => true
        }.to_json
        url = "#{Authy.api_uri}/protected/json/users/#{user_id}/update"
        new_email = generate_email
        expect(Authy::API.http_client).to receive(:request)
          .once
          .with(:post, url, {
            body: Utils.escape_query({
              email: new_email
            }),
            header: headers
          })
          .and_return(double(ok?: true, body: response_json, status: 200))
        response = Authy::API.update_user(id: user_id, email: new_email)
        expect(response.message).to eq "User was updated successfully"
        expect(response).to be_ok
      end
    end
  end

  describe "delete users" do
    context "user doesn't exist" do
      it "should not be ok" do
        url = "#{Authy.api_uri}/protected/json/users/delete/tony"
        response_json = {
          "message" => "User not found.",
          "success" => false,
          "errors" => {
            "message" => "User not found."
          },
          "error_code" => "60026"
        }.to_json
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, {
          :header => headers,
          :body => ""
        })
        .and_return(double(:status => 404, :body => response_json))
        response = Authy::API.delete_user(id: "tony")
        expect(response.errors["message"]).to eq "User not found."
        expect(response).to_not be_ok
      end
    end

    context "user exists" do
      let(:url) { "#{Authy.api_uri}/protected/json/users/delete/31567" }
      it "should be ok" do
        response_json = {
          "message" => "User removed from application",
          "success" => false
        }.to_json
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, {
          :header => headers,
          :body => ""
        })
        .and_return(double(:status => 200, :body => response_json))
        response = Authy::API.delete_user(id: 31567)
        expect(response.message).to eq "User removed from application"
        expect(response).to be_ok
      end
    end
  end

  describe "user status" do
    context "user doesn't exist" do
      it "should not be ok" do
        url = "#{Authy.api_uri}/protected/json/users/tony/status"
        response_json = {
          "message" => "User not found.",
          "success" => false,
          "errors" => {
            "message" => "User not found."
          },
          "error_code" => "60026"
        }.to_json
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, url, {
          :header => headers,
          :query => {},
          :follow_redirect => nil
        })
        .and_return(double(:status => 404, :body => response_json))
        response = Authy::API.user_status(id: "tony")
        expect(response.errors["message"]).to eq "User not found."
        expect(response).to_not be_ok
      end
    end

    context "user exists" do
      it "should be ok" do
        url = "#{Authy.api_uri}/protected/json/users/290907/status"
        response_json = {
          "status" => {
            "authy_id" => 290907,
            "confirmed" => true,
            "registered" => false,
            "country_code" => 1,
            "phone_number" => "XXX-XXX-1118",
            "email" => "alfvawmu@authy.com",
            "devices" => [],
            "has_hard_token" => false,
            "account_disabled" => false,
            "detailed_devices" => [{
              "device_type" => "authy",
              "os_type" => "unknown",
              "registration_device_id" => nil,
              "registration_method" => nil,
              "device_id" => 290908,
              "last_sync_date" => 0,
              "creation_date" => 1433868212
            }],
            "deleted_devices" => []
          },
          "message" => "User status.",
          "success" => true
        }.to_json
        expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, url, {
          :header => headers,
          :query => {},
          :follow_redirect => nil
        })
        .and_return(double(:status => 200, :body => response_json))
        response = Authy::API.user_status(id: 290907)
        expect(response.status).to be_kind_of(Hash)
        expect(response).to be_ok
      end
    end
  end

  describe "blank params" do
    [:request_sms, :request_phone_call, :delete_user].each do |method|
      it "should return a proper response with the errors for #{method}" do
        expect(Authy::API.http_client).to receive(:request).never
        response = Authy::API.send(method, id: nil)
        expect(response).to_not be_ok
        expect(response.message).to eq "user_id is blank."
      end
    end

    it "should return a prope response with the errors for verify" do
      expect(Authy::API.http_client).to receive(:request).never
      response = Authy::API.verify({})
      expect(response).to_not be_ok
      expect(response.message).to eq "Token format is invalid"
    end
  end

  describe ".token_is_safe?" do
    it "checks minimum token size" do
      expect(Authy::API.send(:token_is_safe?, "1")).to be false
    end

    it "checks valid characters" do
      expect(Authy::API.send(:token_is_safe?, "123456")).to be true
      expect(Authy::API.send(:token_is_safe?, "123456a")).to be false
    end

    it "checks maximum token size" do
      expect(Authy::API.send(:token_is_safe?, "123456789098")).to be true
      expect(Authy::API.send(:token_is_safe?, "1234567890987")).to be false
    end
  end
end
