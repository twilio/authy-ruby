module Authy
  #
  #  Authy.api_key = 'foo'
  #  Authy.api_uri = 'http://test-authy-api.heroku.com/'
  #  Authy.moving_factor
  #
  class API
    include Typhoeus
    include Authy::RemoteMethod

    remote_defaults :on_success => lambda {|response| Authy::Response.new(response) },
                    :on_failure => lambda {|response| Authy::Response.new(response) },
                    :base_uri   => ENV['AUTHY_URL'] || 'http://api.authy.com'

    # Authy::API.moving_factor
    define_remote_method :moving_factor, :path => '/json/moving_factor/show'

    # Authy::API.verify(:id => '', :token => '')
    define_remote_method :verify, :path => '/protected/json/verify/:token/:id'

    # Authy::API.register_user(:user => {:email => 'foo@bar.com'})
    define_remote_method :register_user, :path => "/protected/json/users/new",
                                         :method => :post,
                                         :required => [:user],
                                         :on_success => lambda {|response| Authy::User.new(response)  }
  end
end
