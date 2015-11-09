module Authy
  class PhoneIntelligence < Authy::API

    # @deprecated
    def self.verification_start(params)
      warn "[DEPRECATION] `PhoneIntelligence.verification_start` is deprecated.  Please use `PhoneVerification.verification_start` instead."
      Authy::PhoneVerification.verification_start(params)
    end

    # @deprecated
    def self.verification_check(params)
      warn "[DEPRECATION] `PhoneIntelligence.verification_check` is deprecated.  Please use `PhoneVerification.verification_check` instead."
      Authy::PhoneVerification.verification_check(params)
    end

    # options:
    #   :country_code Numeric calling country code of the country.
    #   :phone_number The persons phone number.
    def self.info(params)
      get_request("protected/json/phones/info", params)
    end
  end
end
