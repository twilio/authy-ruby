module Authy
  class PhoneVerification < Authy::API
    # options:
    #   :via (sms|call)
    #   :country_code Numeric calling country code of the country.
    #   :phone_number The persons phone number.
    #   :custom_code Pass along any generated custom code.
    #   :custom_message Custom Message.
    #   :code_length Length of code to be sent(4-10).
    #   :locale The language of the message received by user. 
    def self.start(params)
      params[:via] = "sms" unless %w(sms, call).include?(params[:via])

      post_request("protected/json/phones/verification/start", params)
    end

    # options:
    #   :country_code Numeric calling country code of the country.
    #   :phone_number The persons phone number.
    #   :verification_code The verification code entered by the user.
    def self.check(params)
      get_request("protected/json/phones/verification/check", params)
    end

  end
end
