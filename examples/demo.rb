#!/usr/bin/env ruby

require 'authy' # gem install authy
require 'sqlite3'
require 'active_record'
require 'highline/import' # gem install highline

trap("SIGINT") { exit! }

# setup db
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "db")
class AddUsers < ActiveRecord::Migration[6.0]
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :authy_id
    end
  end

  def self.down
    drop_table :users
  end
end
AddUsers.migrate(:up) if !File.exist?("db")

class User < ActiveRecord::Base
  validates_uniqueness_of :email
end

api_key = ENV["AUTHY_API_KEY"] || ask("Enter your Authy API Key (won't be displayed): "){ |q| q.echo = false }

Authy.api_url = "https://api.authy.com"
Authy.api_key = api_key

choose do |menu|
  menu.prompt = "What do you want to do? "

  menu.choice("Register a user") do
    loop do
      email = ask("email: ")
      country_code = ask("country code: ")
      cellphone = ask("cellphone: ")

      if user = User.where(:email => email).first
        puts "You're already registered with authy id: #{user.authy_id}"
        break
      end

      # register user on authy. email, country code and cellphone are mandatory
      authy_user = Authy::API.register_user(:email => email, :country_code => country_code, :cellphone => cellphone)
      if authy_user.ok?
        puts "User was registered. its authy id is #{authy_user.id}"
        User.create!(:authy_id => authy_user.id, :email => email)
        break
      else
        puts "Failed to register user: #{authy_user.errors}"
      end
    end
  end

  menu.choice("Request token") do
    email = ask("email: ")

    user = User.where(:email => email).first
    if !user
      puts "User is not registered yet"
      return
    end

    # send sms to the user. `force` makes it send the sms even if the user uses a smartphone
    # this api call will return an error if the account doesn't have the SMS addon enabled
    response = Authy::API.request_sms(:id => user.authy_id, :force => true)

    if response.ok?
      puts "Message was sent"
    else
      puts "Failed to send message: #{response.errors.inspect}"
    end
  end

  menu.choice("Verify token") do
    email = ask("email: ")

    user = User.where(:email => email).first
    if !user
      puts "User is not registered yet"
      return
    end

    token = ask("token: ")

    # verify if the given token is correct. `force` makes it validate the code even if the user has not confirmed its account
    otp = Authy::API.verify(:id => user.authy_id, :token => token, :force => true)

    if otp.ok?
      puts "Welcome back!"
    else
      puts "Wrong email or token :("
    end
  end
end
