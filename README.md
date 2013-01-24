# Authy

Ruby library to access the Authy API

## Usage

    require 'authy'

    Authy.api_key = 'your-api-key'
    Authy.api_uri = 'https://api.authy.com/'


## Registering a user

__NOTE: User is matched based on cellphone and country code not e-mail.
A cellphone is uniquely associated with an authy_id.__  


`Authy::API.register_user` requires the user e-mail address and cellphone. Optionally you can pass in the country_code or we will asume
USA. The call will return you the authy id for the user that you need to store in your database.

Assuming you have a `users` database with a `authy_id` field in the `users` database.

    authy = Authy::API.register_user(:email => 'users@email.com', :cellphone => "111-111-1111", :country_code => "1")

    if authy.ok?
      self.authy_id = authy.id # this will give you the user authy id to store it in your database
    else
      authy.errors # this will return an error hash
    end


## Verifying a user


__NOTE: Token verification is only enforced if the user has completed registration. To change this behaviour see Forcing Verification section below.__  
   
   >*Registration is completed once the user installs and registers the Authy mobile app or logins once successfully using SMS.*

`Authy::API.verify` takes the authy_id that you are verifying and the token that you want to verify. You should have the authy_id in your database

    response = Authy::API.verify(:id => user.authy_id, :token => 'token-user-entered')

    if response.ok?
      # token was valid, user can sign in
    else
      # token is invalid
    end

### Forcing Verification

If you wish to verify tokens even if the user has not yet complete registration, pass force=true when verifying the token.

    response = Authy::API.verify(:id => user.authy_id, :token => 'token-user-entered', :force => true)

## Requesting a SMS token

`Authy::API.request_sms` takes the authy_id that you want to send a SMS token. This requires Authy SMS plugin to be enabled.

    response = Authy::API.request_sms(:id => user.authy_id)

    if response.ok?
      # sms was sent
    else
      response.errors
      #sms failed to send
    end


This call will be ignored if the user is using the Authy Mobile App. If you still want to send
the SMS pass force=true as an option

    response = Authy::API.request_sms(:id => user.authy_id, :force => true)


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

Copyright (c) 2012 Authy Inc. See LICENSE.txt for
further details.
