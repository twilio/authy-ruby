module Authy
  #
  #  Authy.api_key = 'foo'
  #  Authy.api_uri = 'http://test-authy-api.heroku.com/'
  #
  class API
    include Typhoeus

    def self.register_user(attributes)
      user_data = {
        :user => attributes,
        :api_key => Authy.api_key
      }

      response = Typhoeus::Request.post("#{Authy.api_uri}/protected/json/users/new", :params => user_data)

      Authy::User.new(response)
    end

    # options:
    # :id user id
    # :token authy token entered by the user
    def self.verify(attributes)
      token = attributes[:token] || attributes['token']
      user_id = attributes[:id] || attributes['id']
      response = Typhoeus::Request.get("#{Authy.api_uri}/protected/json/verify/#{token}/#{user_id}", :params => {:api_key => Authy.api_key})

      Authy::Response.new(response)
    end

    # options:
    # :id user id
    def self.request_sms(attributes)
      user_id = attributes[:id] || attributes['id']

      response = Typhoeus::Request.get("#{Authy.api_uri}/protected/json/sms/#{user_id}", :params => {:api_key => Authy.api_key})

      Authy::Response.new(response)
    end
  end
end
