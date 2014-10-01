require 'spec_helper'

describe "Authy::PhoneIntelligence" do
  describe "Sending the verification code" do

    it "should send the code via SMS" do
      response = Authy::PhoneIntelligence.verification_start(
        :via => "sms",
        :country_code => "1",
        :phone_number => "111-111-1111"
      )

      response.should be_kind_of(Authy::Response)
      response.should be_ok
      response.message.should == "Text message sent to +1 111-111-1111."
    end

    # it "should send the code via CALL" do
    #   response = Authy::PhoneIntelligence.verification_start(
    #     :via => "call",
    #     :country_code => "1",
    #     :phone_number => "111-111-1111"
    #   )

    # response.should be_kind_of(Authy::Response)
    #   response.success.should be_true
    #   response.message.should == "Text message sent to +1 111-111-1111."
    # end
  end

  describe "validate the fields required" do
    it "should return an error. Country code is required" do
      response = Authy::PhoneIntelligence.verification_start(
        :via => "sms",
        :phone_number => "111-111-1111"
      )

      response.should_not be_ok
      response.errors['message'] =~ /Country code is mandatory/
    end

    it "should return an error. Cellphone is invalid" do
      response = Authy::PhoneIntelligence.verification_start(
        :via => "sms",
        :country_code => "1",
        :phone_number => "123"
      )

      response.should_not be_ok
      response.errors['message'] =~ /Phone number is invalid/
    end
  end

  describe "Check the verification code" do
    it "should return success true if code is correct" do
      response = Authy::PhoneIntelligence.verification_check(
        :country_code => "1",
        :phone_number => "111-111-1111",
        :verification_code => "0000"
      )

      response.should be_ok
      response.message.should == "Verification code is correct."
    end

    it "should return an error if code is incorrect" do
      response = Authy::PhoneIntelligence.verification_check(
        :country_code => "1",
        :phone_number => "111-111-1111",
        :verification_code => "1234"
      )

      response.should_not be_ok
      response.message.should == "Verification code is incorrect."
    end
  end

  describe "Requesting phone number information" do
    it "should return the phone information" do
      response = Authy::PhoneIntelligence.info(
        :country_code => "1",
        :phone_number => "7754615609"
      )

      response.should be_ok
      response.message.should =~ /Phone number information as of/
      response.type.should == "voip"
      response.provider.should == "Google Voice"
      response.ported.should be_false
    end
  end
end
