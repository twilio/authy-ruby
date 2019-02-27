require 'spec_helper'

describe "Authy::PhoneVerification" do
  describe "Sending the verification code" do

    it "should send the code via SMS" do
      pending("API is not returning expected response in this case. The test phone number is invalid.")
      response = Authy::PhoneVerification.start(
        via: "sms",
        country_code: "1",
        phone_number: "111-111-1111"
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
      expect(response.message).to eq "Text message sent to +1 111-111-1111."
    end

    it "should send the code via SMS with code length" do
      response = Authy::PhoneVerification.start(
        via: "sms",
        country_code: "1",
        phone_number: "2015550123",
        code_length: "4"
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
      expect(response.message).to eq "Text message sent to +1 2015550123."
    end

    # it "should send the code via CALL" do
    #   response = Authy::PhoneVerification.start(
    #     via: "call",
    #     country_code: "1",
    #     phone_number: "111-111-1111"
    #   )

    # response.should be_kind_of(Authy::Response)
    #   response.success.should be_truthy
    #   response.message.should == "Text message sent to +1 111-111-1111."
    # end
  end

  describe "validate the fields required" do
    it "should return an error. Country code is required" do
      response = Authy::PhoneVerification.start(
        via: "sms",
        phone_number: "111-111-1111"
      )


      expect(response).to_not be_ok
      expect(response.errors['message']).to match(/country_code - Parameter is required/)
    end

    it "should return an error. Cellphone is invalid" do
      response = Authy::PhoneVerification.start(
        via: "sms",
        country_code: "1",
        phone_number: "123"
      )

      expect(response).to_not be_ok
      expect(response.errors['message']).to eq('Phone number is invalid')
    end
  end

  describe 'Check that a custom code request' do
    it "should return an error if not enabled" do
      pending("API is not returning expected response in this case. The test phone number is invalid")

      response = Authy::PhoneVerification.start(
        country_code: "1",
        phone_number: "111-111-1111",
        custom_code: "1234"
      )
      expect(response).not_to be_ok
      expect(response.message).to eq("Phone verification couldn't be created: custom codes are not allowed.")
    end
  end

  describe "Check the verification code" do
    it "should return success true if code is correct" do
      pending("API is not returning expected response in this case. The test phone number is invalid.")

      response = Authy::PhoneVerification.check(
        country_code: "1",
        phone_number: "111-111-1111",
        verification_code: "0000"
      )

      expect(response).to be_ok
      expect(response.message).to eq('Verification code is correct.')
    end

    it "should return an error if code is incorrect" do
      pending("API is not returning expected response in this case. The test phone number is invalid")

      response = Authy::PhoneVerification.check(
        country_code: "1",
        phone_number: "111-111-1111",
        verification_code: "1234"
      )

      expect(response).not_to be_ok
      expect(response.message).to eq('Verification code is incorrect.')
    end
  end

  describe 'Check the phone number' do
    it "should return an error if phone number is invalid" do
      response = Authy::PhoneVerification.check(
        country_code: "1",
        phone_number: "111-111-1111",
        verification_code: "1234"
      )

      expect(response).not_to be_ok
      expect(response.message).to eq('Phone number is invalid')
    end
  end

end
