# Authy [![Build Status](https://travis-ci.org/authy/authy-ruby.png?branch=master)](https://travis-ci.org/authy/authy-ruby) [![Code Climate](https://codeclimate.com/github/authy/authy-ruby.png)](https://codeclimate.com/github/authy/authy-ruby)

Ruby library to access the Authy API

## Usage

```ruby
    require 'authy'

    Authy.api_key = 'your-api-key'
    Authy.api_uri = 'https://api.authy.com/'
```

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

### Contributing to authy

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
==

Copyright (c) 2012-2013 Authy Inc. See LICENSE.txt for
further details.
