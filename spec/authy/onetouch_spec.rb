require 'spec_helper'

class Utils
  include Authy::URL
end

describe Authy::OneTouch do
  let(:headers) { { "X-Authy-API-Key" => Authy.api_key, "User-Agent" => "AuthyRuby/#{Authy::VERSION} (#{RUBY_PLATFORM}, Ruby #{RUBY_VERSION})" } }
  let(:user_id) { 81547 }

  describe ".send_approval_request" do
    let(:url) { "#{Authy.api_url}/onetouch/json/users/#{user_id}/approval_requests" }
    it 'creates a new approval_request for user' do
      response_json = {
        "approval_request" => {
          "uuid" => "550e8400-e29b-41d4-a716-446655440000"
        },
        "success" => true
      }.to_json
      params = {
        message: 'You are moving 10 BTC from your account',
        details: {
          'Bank account' => '23527922',
          'Amount' => '10 BTC',
        },
        hidden_details: {
          'IP Address' => '192.168.0.3'
        },
        seconds_to_expire: 150
      }

      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, {
          :body => Utils.escape_query(params),
          :header => headers
        })
        .and_return(double(:status => 200, :body => response_json))

      params[:id] = user_id
      response = Authy::OneTouch.send_approval_request(params)

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end

    it 'requires message as mandatory' do
      expect(Authy::API.http_client).to receive(:request).never
      response = Authy::OneTouch.send_approval_request(
        id: user_id,
        details: {
          'Bank account' => '23527922',
          'Amount' => '10 BTC',
        },
        hidden_details: {
          'IP Address' => '192.168.0.3'
        }
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to_not be_ok
      expect(response.message).to eq 'message cannot be blank'
    end

    it 'does not require other fields as mandatory' do
      response_json = {
        "approval_request" => {
          "uuid" => "550e8400-e29b-41d4-a716-446655440000"
        },
        "success" => true
      }.to_json
      params = {
        message: 'You are moving 10 BTC from your account'
      }

      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, {
          :body => Utils.escape_query(params),
          :header => headers
        })
        .and_return(double(:status => 200, :body => response_json))

      params[:id] = user_id
      response = Authy::OneTouch.send_approval_request(params)

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end

    it 'checks logos format' do
      response_json = {
        "approval_request" => {
          "uuid" => "550e8400-e29b-41d4-a716-446655440000"
        },
        "success" => true
      }.to_json
      params = {
        message: 'You are moving 10 BTC from your account',
        details: {
          'Bank account' => '23527922',
          'Amount' => '10 BTC',
        },
        hidden_details: {
          'IP Address' => '192.168.0.3'
        },
        logos: [{res: 'low', url: 'http://foo.bar'}],
        seconds_to_expire: 150
      }
      expect(Authy::API.http_client).to receive(:request)
        .once
        .with(:post, url, {
          :body => Utils.escape_query(params),
          :header => headers
        })
        .and_return(double(:status => 200, :body => response_json))

      params[:id] = user_id
      response = Authy::OneTouch.send_approval_request(params)

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end
  end

  describe '.approval_request_status' do
    it 'returns approval request status' do
      uuid = '550e8400-e29b-41d4-a716-446655440000'
      url = "#{Authy.api_url}/onetouch/json/approval_requests/#{uuid}"
      response_json = {
        "approval_request" => {
          "status" => "pending"
        },
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
      response = Authy::OneTouch.approval_request_status(uuid: uuid)

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end
  end
end
