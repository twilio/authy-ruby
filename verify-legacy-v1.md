# Phone Verification V1

[Version 2 of the Verify API is now available!](https://www.twilio.com/docs/verify/api) V2 has an improved developer experience and new features. Some of the features of the V2 API include:

* Twilio helper libraries in JavaScript, Java, C#, Python, Ruby, and PHP
* PSD2 Secure Customer Authentication Support
* Improved Visibility and Insights

You are currently viewing Version 1. V1 of the API will be maintained for the time being, but any new features and development will be on Version 2. We strongly encourage you to do any new development with API V2. Check out the migration guide or the API Reference for more information.

### API Reference

API Reference is available at https://www.twilio.com/docs/verify/api/v1

### Starting a phone verification

`Authy::PhoneVerification.start` takes a country code, phone number and a method (sms or call) to deliver the code.

```ruby
response = Authy::PhoneVerification.start(via: "sms", country_code: 1, phone_number: "111-111-1111")
if response.ok?
  # verification was started
end
```

### Checking a phone verification

`Authy::PhoneVerification.check` takes a country code, phone number and a verification code.

```ruby
response = Authy::PhoneVerification.check(verification_code: "1234", country_code: 1, phone_number: "111-111-1111")
if response.ok?
  # verification was successful
end
```