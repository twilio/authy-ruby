module Authy
  class PhoneIntelligence < Authy::API

    # @deprecated
    def self.verification_start(params)
      warn "[DEPRECATION] `PhoneIntelligence.verification_start` is deprecated.  Please use `PhoneVerification.start` instead."
      Authy::PhoneVerification.start(params)
    end

    # @deprecated
    def self.verification_check(params)
      warn "[DEPRECATION] `PhoneIntelligence.verification_check` is deprecated.  Please use `PhoneVerification.check` instead."
      Authy::PhoneVerification.check(params)
    end

    # options:
    #   :country_code Numeric calling country code of the country.
    #   :phone_number The persons phone number.
    def self.info(params)
      get_request("protected/json/phones/info", params)
    end
  end
end
