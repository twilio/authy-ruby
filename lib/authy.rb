$:.unshift File.expand_path("..", __FILE__)

require 'bundler/setup'

require 'typhoeus'
require 'json'
require 'authy/response'
require 'authy/models/user'
require 'authy/config'
require 'authy/api'
