require 'spec_helper'

describe Authy::OneTouch do
  describe ".send_approval_request" do

    before do
      @email = generate_email
      @cellphone = generate_cellphone
      @user = Authy::API.register_user(:email => @email,
                                       :cellphone => @cellphone,
                                       :country_code => 1)
      expect(@user).to be_ok
    end

    it 'creates a new approval_request for user' do
      pending('The Authy account this test uses needs to have OneTouch enabled. Another option is to mock the API')
      response = Authy::OneTouch.send_approval_request(
        id: @user.id,
        message: 'You are moving 10 BTC from your account',
        details: {
          'Bank account' => '23527922',
          'Amount' => '10 BTC',
        },
        hidden_details: {
          'IP Address' => '192.168.0.3'
        },
        seconds_to_expire: 150
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end

    it 'requires message as mandatory' do
      response = Authy::OneTouch.send_approval_request(
        id: @user.id,
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
      pending('The Authy account this test uses needs to have OneTouch enabled. Another option is to mock the API')
      response = Authy::OneTouch.send_approval_request(
        id: @user.id,
        message: 'Test message'
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end

    it 'checks logos format' do
      pending('The Authy account this test uses needs to have OneTouch enabled. Another option is to mock the API')
      response = Authy::OneTouch.send_approval_request(
        id: @user.id,
        message: 'You are moving 10 BTC from your account',
        details: {
          'Bank account' => '23527922',
          'Amount' => '10 BTC',
        },
        hidden_details: {
          'IP Address' => '192.168.0.3'
        },
        seconds_to_expire: 150,
        logos: [{res: 'low', url: 'http://foo.bar'}]
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end
  end

  describe '.approval_request_status' do
    it 'returns approval request status' do
      pending('The Authy account this test uses needs to have OneTouch enabled. Another option is to mock the API')
      response = Authy::OneTouch.approval_request_status(
        uuid: '550e8400-e29b-41d4-a716-446655440000'
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
    end
  end
end
