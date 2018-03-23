require 'authy' # gem install authy

Authy.api_url = "https://api.authy.com"
Authy.api_key = "[YOUR_API_KEY]"

# Custom Code example
# response = Authy::PhoneVerification.start(via: "sms", country_code: 1, phone_number: "[YOUR_NUMBER]", custom_code: "1234")

response = Authy::PhoneVerification.start(via: "sms", country_code: [YOUR_COUNTRY_CODE], phone_number: "[YOUR_PHONE_NUMBER]")
if response.ok?
  # verification was started
end
