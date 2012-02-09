module Authy
  #
  #  Authy.api_key = 'foo'
  #  Authy.api_uri = 'http://test-authy-api.heroku.com/'
  #  Authy.moving_factor
  #
  class API
    include Typhoeus
    include Authy::RemoteMethod

    remote_defaults :on_success => lambda {|response| JSON.parse(response.body) rescue response.body },
                    :on_failure => lambda {|response| JSON.parse(response.body) rescue response.body },
                    :base_uri   => ENV['AUTHY_URL'] || 'http://api.authy.com'

    # Authy::API.moving_factor
    define_remote_method :moving_factor, :path => '/json/moving_factor/show'

    # Authy::API.verify(:id => '', :otp => '')
    define_remote_method :verify, :path => '/protected/json/verify/:otp/:id'

    # Authy::API.register_user(:user => {:email => 'foo@bar.com'})
    define_remote_method :register_user, :path => "/protected/json/users/new",
                                         :method => :post,
                                         :required => [:user]
  end
end
