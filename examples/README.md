# Demo

In this `example` directory is a demo of using the Twilio Authy Two-Factor Authentication (2FA) API with the Authy gem.

## How does it work?

The demo works on the command line and allows you to register a user in your Authy application, request a token for that user and verify a token for a user. Registered users and their authy_id token are stored in a local SQLite database.

## How to use the demo

Change into the `examples` directory and install the dependencies with:

```bash
bundle install
```

Then, run the demo with:

```bash
./demo.rb
```

You will be asked for your Authy API key then presented a list of options.

```bash
$ ./demo.rb

Enter your Authy API Key (won't be displayed):
1. Register a user
2. Request token
3. Verify token
What do you want to do?
```

On the first run, choose to register a user. This will ask you for an email address, country code and phone number. With those details a user will be registered with your Authy application and stored in your local database.

Then you can run the application and either request a token, to have a token sent by SMS, or verify a token, you can use the token from an SMS or the Authy app to verify.

### API keys

You will be asked for your Authy API key each time you run the demo. You can avoid this by [adding your Authy API key to your environment variables](https://www.twilio.com/blog/2017/01/how-to-set-environment-variables.html).

```
export AUTHY_API_KEY=ABC123xxxxx
./demo.rb
```

Check out the code in `./examples/demo.rb` to see how the API and this gem is used.
