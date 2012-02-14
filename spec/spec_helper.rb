$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'authy'
require 'pry'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:suite) do
    Authy.api_uri = 'http://staging-1.authy.com'
    Authy.api_key = '41af600547406a6217db1c82fae313a7'
  end

  config.before(:each) do
  end

  config.after(:each) do
  end

  def generate_email
    domain = "@authy.com"
    user = (0...8).map{97.+(rand(25)).chr}.join
    user + domain
  end
end
