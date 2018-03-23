# Authy [![Build Status](https://travis-ci.org/authy/authy-ruby.png?branch=master)](https://travis-ci.org/authy/authy-ruby) [![Code Climate](https://codeclimate.com/github/authy/authy-ruby.png)](https://codeclimate.com/github/authy/authy-ruby)

Ruby library to access the Authy API

## Usage

```ruby
    require 'authy'

    Authy.api_key = 'your-api-key'
    Authy.api_uri = 'https://api.authy.com/'
```

Using Ruby on Rails? _Put this in **config/initializers** and create a new file called **authy.rb**._

## Registering a user

__NOTE: User is matched based on cellphone and country code not e-mail.
A cellphone is uniquely associated with an authy_id.__


`Authy::API.register_user` requires the user e-mail address and cellphone. Optionally you can pass in the country_code or we will asume
USA. The call will return you the authy id for the user that you need to store in your database.

Assuming you have a `users` database with a `authy_id` field in the `users` database.

```ruby
    authy = Authy::API.register_user(:email => 'users@email.com', :cellphone => "111-111-1111", :country_code => "1")

    if authy.ok?
      self.authy_id = authy.id # this will give you the user authy id to store it in your database
    else
      authy.errors # this will return an error hash
    end
```

## Verifying a user


__NOTE: Token verification is only enforced if the user has completed registration. To change this behaviour see Forcing Verification section below.__

   >*Registration is completed once the user installs and registers the Authy mobile app or logins once successfully using SMS.*

`Authy::API.verify` takes the authy_id that you are verifying and the token that you want to verify. You should have the authy_id in your database

```ruby
    response = Authy::API.verify(:id => user.authy_id, :token => 'token-user-entered')

    if response.ok?
      # token was valid, user can sign in
    else
      # token is invalid
    end
```

### Forcing Verification

If you wish to verify tokens even if the user has not yet complete registration, pass force=true when verifying the token.

```ruby
    response = Authy::API.verify(:id => user.authy_id, :token => 'token-user-entered', :force => true)
```

## Requesting a SMS token

`Authy::API.request_sms` takes the authy_id that you want to send a SMS token. This requires Authy SMS plugin to be enabled.

```ruby
    response = Authy::API.request_sms(:id => user.authy_id)

    if response.ok?
      # sms was sent
    else
      response.errors
      #sms failed to send
    end
```

This call will be ignored if the user is using the Authy Mobile App. If you still want to send
the SMS pass force=true as an option

```ruby
    response = Authy::API.request_sms(:id => user.authy_id, :force => true)
```

If you wish to send SMS in a specific language, you can provide locale information in the params as shown below.

```ruby
    response = Authy::API.request_sms(:id => user.authy_id, :force => true, :locale => 'es')
```

If the locale that you provide is wrong or does not match, the SMS will be sent in english.

## Requesting token via a phone call

`Authy::API.request_phone_call` takes the authy_id that you want to deliver the token by a phone call. This requires Authy Calls addon, please contact us to support@authy.com to enable this addon.

```ruby
    response = Authy::API.request_phone_call(:id => user.authy_id)

    if response.ok?
      # call was done
    else
      response.errors
      # call failed
    end
```

This call will be ignored if the user is using the Authy Mobile App. If you ensure that user receives the phone call, you must pass force=true as an option

```ruby
    response = Authy::API.request_phone_call(:id => user.authy_id, :force => true)
```

## Deleting users

`Authy::API.delete_user` takes the authy_id of the user that you want to remove from your app.

```ruby
    response = Authy::API.delete_user(:id => user.authy_id)

    if response.ok?
      # the user was deleted
    else
      response.errors
      # we were unavailable to delete the user
    end
```

## User status

`Authy::API.user_status` takes the authy_id of the user that you want to get the status from your app.

```ruby
    response = Authy::API.user_status(:id => user.authy_id)

    if response.ok?
      # do something with user status
    else
      response.errors
      # the user doesn't exist
    end
```

## Phone Verification

### Starting a phone verification

`Authy::PhoneVerification.start` takes a country code, phone number and a method (sms or call) to deliver the code.  You can also provide a custom_code but this feature needs to be enabled by support@twilio.com

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

## OneTouch Verification

Another way to provide Two_factor authentication with Authy is by using OneTouch feature. 
Check the [official docs](http://docs.authy.com/onetouch_getting_started.html)

`Authy::OneTouch.send_approval_request` takes the Authy user ID, a message to fill up the push notification
body, an optional hash details for the user and another optional hash for hidden details for internal app
control.

```ruby
one_touch = Authy::OneTouch.send_approval_request(
        id: @user.authy_id,
        message: "Request to Login",
        details: {
          'Email Address' => @user.email,
        },
        hidden_details: { ip: '1.1.1.1' }
      )
```

As soon as the user approves or reject the push notification, Authy will hit a callback endpoint
(set into Dashboard) updating user's `authy_status` flag. You might have an endpoint in a controller
such as:

```ruby
def callback
    authy_id = params[:authy_id]
    @user = User.find_by authy_id: authy_id
    @user.update(authy_status: params[:status])
  end
```


## Contributing to authy

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
==

Copyright (c) 2011-2020 Authy Inc. See LICENSE.txt for
further details.
