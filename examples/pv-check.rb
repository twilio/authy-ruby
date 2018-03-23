require 'authy' # gem install authy

Authy.api_url = "https://api.authy.com"
Authy.api_key = "[YOUR_API_KEY]"

response = Authy::PhoneVerification.check(verification_code: "1234", country_code: [YOUR_COUNTRY_CODE], phone_number: "[YOUR_PHONE_NUMBER]")
if response.ok?
  # verification was started
end
