require 'spec_helper'

class Utils
  include Authy::URL
end

describe "Authy::PhoneVerification" do
  let(:valid_phone_number) { '201-555-0123' }
  let(:invalid_phone_number) { '123' }
  let(:headers) { { "X-Authy-API-Key" => Authy.api_key, "User-Agent" => "AuthyRuby/#{Authy::VERSION} (#{RUBY_PLATFORM}, Ruby #{RUBY_VERSION})" } }
  let(:start_url) { "#{Authy.api_url}/protected/json/phones/verification/start" }
  let(:check_url) { "#{Authy.api_url}/protected/json/phones/verification/check"}

  describe "Sending the verification code" do
    it "should send the code via SMS" do
      response_json = {
        "carrier" => "Fixed Line Operators and Other Networks",
        "is_cellphone" => true,
        "is_ported" => false,
        "message" => "Text message sent to +1 201-555-0123.",
        "seconds_to_expire" => 0,
        "uuid" => nil,
        "success" => true
      }.to_json
      params = {
        via: "sms",
        country_code: "1",
        phone_number: valid_phone_number
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, start_url, {
          :body => Utils.escape_query(params),
          :header => headers
        })
        .and_return(double(:status => 200, :body => response_json))
      response = Authy::PhoneVerification.start(params)
      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
      expect(response.message).to eq "Text message sent to +1 #{valid_phone_number}."
    end

    it "should send the code via SMS with code length" do
      response_json = {
        "carrier" => "Fixed Line Operators and Other Networks",
        "is_cellphone" => true,
        "is_ported" => false,
        "message" => "Text message sent to +1 201-555-0123.",
        "seconds_to_expire" => 0,
        "uuid" => nil,
        "success" => true
      }.to_json
      params = {
        via: "sms",
        country_code: "1",
        phone_number: valid_phone_number,
        code_length: "4"
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, start_url, {
          :body => Utils.escape_query(params),
          :header => headers
        })
        .and_return(double(:status => 200, :body => response_json))
      response = Authy::PhoneVerification.start(params)

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
      expect(response.message).to eq "Text message sent to +1 #{valid_phone_number}."
    end
  end

  describe "validate the fields required" do
    it "should return an error. Country code is required" do
      response_json = {
        "error_code" => "60004",
        "message" => "Invalid parameter: country_code - Parameter is required",
        "errors" => {
          "message" => "Invalid parameter: country_code - Parameter is required"
        },
        "success" => false
      }.to_json
      params = {
        via: "sms",
        phone_number: valid_phone_number
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, start_url, {
          :body => Utils.escape_query(params),
          :header => headers
        })
        .and_return(double(:status => 400, :body => response_json))
      response = Authy::PhoneVerification.start(params)

      expect(response).to_not be_ok
      expect(response.errors['message']).to match(/country_code - Parameter is required/)
    end

    it "should return an error. Cellphone is invalid" do
      response_json = {
        "error_code" => "60033",
        "message" => "Phone number is invalid",
        "errors" => {
          "message" => "Phone number is invalid"
        },
        "success" => false
      }.to_json
      params = {
        via: "sms",
        country_code: "1",
        phone_number: invalid_phone_number
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, start_url, {
          :body => Utils.escape_query(params),
          :header => headers
        })
        .and_return(double(:status => 400, :body => response_json))
      response = Authy::PhoneVerification.start(params)

      expect(response).to_not be_ok
      expect(response.errors['message']).to eq('Phone number is invalid')
    end
  end

  describe "Check the verification code" do
    it "should return success true if code is correct" do
      response_json = {
        "message" => "Verification code is correct.",
        "success" => true
      }.to_json
      params = {
        country_code: "1",
        phone_number: valid_phone_number,
        verification_code: "0000"
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, check_url, {
          :query => params,
          :header => headers,
          :follow_redirect => nil
        })
        .and_return(double(:status => 200, :body => response_json))
      response = Authy::PhoneVerification.check(params)

      expect(response).to be_ok
      expect(response.message).to eq('Verification code is correct.')
    end

    it "should return an error if code is incorrect" do
      response_json = {
        "error_code" => "60022",
        "message" => "Verification code is incorrect",
        "errors" => {
          "message" => "Verification code is incorrect"
        },
        "success" => false
      }.to_json
      params = {
        country_code: "1",
        phone_number: valid_phone_number,
        verification_code: "1234"
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, check_url, {
          :query => params,
          :header => headers,
          :follow_redirect => nil
        })
        .and_return(double(:status => 401, :body => response_json))
      response = Authy::PhoneVerification.check(params)

      expect(response).not_to be_ok
      expect(response.message).to eq('Verification code is incorrect')
    end

    it "should return an error if there are no active verifications" do
      response_json = {
        "message" => "No pending verifications for #{valid_phone_number} found.",
        "success" => false,
        "errors" => {
          "message" => "No pending verifications for #{valid_phone_number} found."
        },
        "error_code" => "60023"
      }.to_json
      params = {
        :country_code => "1",
        :phone_number => valid_phone_number,
        :verification_code => "1234"
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, check_url, {
          :query => params,
          :header => headers,
          :follow_redirect => nil
        })
        .and_return(double(:status => 404, :body => response_json))

      response = Authy::PhoneVerification.check(params)

      expect(response).not_to be_ok
      expect(response.message).to eq("No pending verifications for #{valid_phone_number} found.")
    end
  end

  describe 'Check the phone number' do
    it "should return an error if phone number is invalid" do
      response_json = {
        "error_code" => "60033",
        "message" => "Phone number is invalid",
        "errors" => {
          "message" => "Phone number is invalid"
        },
        "success" => false
      }.to_json
      params = {
        country_code: "1",
        phone_number: invalid_phone_number,
        verification_code: "1234"
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:get, check_url, {
          :query => params,
          :header => headers,
          :follow_redirect => nil
        })
        .and_return(double(:status => 400, :body => response_json))

      response = Authy::PhoneVerification.check(params)
      expect(response).not_to be_ok
      expect(response.message).to eq('Phone number is invalid')
    end
  end

end
