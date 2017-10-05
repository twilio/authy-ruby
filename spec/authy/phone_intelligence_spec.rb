require 'spec_helper'

describe "Authy::PhoneIntelligence" do
  describe "Sending the verification code" do

    it "should send the code via SMS" do
      pending("API is not returning expected response in this case. The test phone number is invalid.")
      response = Authy::PhoneIntelligence.verification_start(
        via: "sms",
        country_code: "1",
        phone_number: "111-111-1111"
      )

      expect(response).to be_kind_of(Authy::Response)
      expect(response).to be_ok
      expect(response.message).to eq "Text message sent to +1 111-111-1111."
    end

    # it "should send the code via CALL" do
    #   response = Authy::PhoneIntelligence.verification_start(
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
      response = Authy::PhoneIntelligence.verification_start(
        via: "sms",
        phone_number: "111-111-1111"
      )

      expect(response).to_not be_ok
      expect(response.errors['message']).to match(/country_code - Parameter is required/)
    end

    it "should return an error. Cellphone is invalid" do
      response = Authy::PhoneIntelligence.verification_start(
        via: "sms",
        country_code: "1",
        phone_number: "123"
      )

      expect(response).to_not be_ok
      expect(response.errors['message']).to match(/Phone number is invalid/)
    end
  end

  describe "Check the verification code" do
    it "should return success true if code is correct" do
      pending("API is not returning expected response in this case. The test phone number is invalid.")

      response = Authy::PhoneIntelligence.verification_check(
        country_code: "1",
        phone_number: "111-111-1111",
        verification_code: "0000"
      )

      expect(response).to be_ok
      expect(response.message).to eq "Verification code is correct."
    end

    it "should return an error if code is incorrect" do
      pending("API is not returning expected response in this case. The test phone number is invalid.")

      response = Authy::PhoneIntelligence.verification_check(
        country_code: "1",
        phone_number: "111-111-1111",
        verification_code: "1234"
      )

      expect(response).to_not be_ok
      expect(response.message).to eq 'Verification code is incorrect.'
    end
  end

  describe "Requesting phone number information" do
    it "should return the phone information" do
      response = Authy::PhoneIntelligence.info(
        country_code: '1',
        phone_number: '7754615609'
      )

      expect(response).to be_ok
      expect(response.message).to match(/Phone number information as of/)
    end
  end
end
