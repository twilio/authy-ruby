$:.unshift File.expand_path("..", __FILE__)

require 'httpclient'
require 'httpclient/include_client'
require 'json'

require 'authy/version'
require 'authy/url_helpers'
require 'authy/response'
require 'authy/models/user'
require 'authy/config'
require 'authy/api'
require 'authy/phone_verification'
require 'authy/onetouch'

warn "DEPRECATION WARNING: The authy-ruby library is no longer actively maintained. The Authy API is being replaced by the Twilio Verify API. Please see the README for more details."