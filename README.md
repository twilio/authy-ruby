[![Build Status](https://travis-ci.org/twilio/authy-ruby.png?branch=master)](https://travis-ci.org/twilio/authy-ruby) [![Code Climate](https://codeclimate.com/github/authy/authy-ruby.png)](https://codeclimate.com/github/authy/authy-ruby)

# Ruby Client for Twilio Authy Two-Factor Authentication (2FA) API

Documentation for Ruby usage of the Authy API lives in the [official Twilio documentation](https://www.twilio.com/docs/authy/api/).

The Authy API supports multiple channels of 2FA:
* One-time passwords via SMS and voice.
* Soft token ([TOTP](https://www.twilio.com/docs/glossary/totp) via the Authy App)
* Push authentication via the Authy App

If you only need SMS and Voice support for one-time passwords, we recommend using the [Twilio Verify API](https://www.twilio.com/docs/verify/api) instead. 

[More on how to choose between Authy and Verify here.](https://www.twilio.com/docs/verify/authy-vs-verify)

### Authy Quickstart

For a full tutorial, check out either of the Ruby Authy Quickstart in our docs:
* [Ruby/Rails Authy Quickstart](https://www.twilio.com/docs/authy/quickstart/two-factor-authentication-ruby-rails)

## Authy Ruby Installation

```
gem install authy
```

## Usage

To use the Authy client, require the `authy` gem and initialize it with our API URI and your production API Key found in the [Twilio Console](https://www.twilio.com/console/authy/applications/):

```ruby
require 'authy'

Authy.api_uri = 'https://api.authy.com'
Authy.api_key = 'your-api-key'
```

Rails users can put this in config/initializers and create a new file called `authy.rb`.

![authy api key in console](https://s3.amazonaws.com/com.twilio.prod.twilio-docs/images/account-security-api-key.width-800.png)

## 2FA Workflow

1. [Create a user](https://www.twilio.com/docs/authy/api/users#enabling-new-user)
2. [Send a one-time password](https://www.twilio.com/docs/authy/api/one-time-passwords)
3. [Verify a one-time password](https://www.twilio.com/docs/authy/api/one-time-passwords#verify-a-one-time-password)

**OR**

1. [Create a user](https://www.twilio.com/docs/authy/api/users#enabling-new-user)
2. [Send a push authentication](https://www.twilio.com/docs/authy/api/push-authentications)
3. [Check a push authentication status](https://www.twilio.com/docs/authy/api/push-authentications#check-approval-request-status)


## <a name="phone-verification"></a>Phone Verification

[Phone verification now lives in the Twilio API](https://www.twilio.com/docs/verify/api) and has [Ruby support through the official Twilio helper libraries](https://www.twilio.com/docs/libraries/ruby). 

[Legacy (V1) documentation here.](verify-legacy-v1.md) **Verify V1 is not recommended for new development. Please consider using [Verify V2](https://www.twilio.com/docs/verify/api)**.

## Contributing

Install development dependencies with pip:

    sudo pip install -r requirements.txt

To run tests:

    make test
or

    make testfile tests/<test_case_file>

## Copyright

Copyright (c) 2011-2020 Authy Inc. See [LICENSE](https://github.com/twilio/authy-ruby/blob/master/LICENSE.txt) for further details.