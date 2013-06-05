module Authy
  #
  #  Authy.api_key = 'foo'
  #  Authy.api_uri = 'http://test-authy-api.heroku.com/'
  #
  class API
    USER_AGENT = "authy-ruby"

    include Authy::URL

    extend HTTPClient::IncludeClient
    include_http_client


    def self.register_user(attributes)
      api_key = attributes.delete(:api_key)
      params = {
        :user => attributes,
        :api_key => api_key || Authy.api_key
      }

      url = "#{Authy.api_uri}/protected/json/users/new"
      response = http_client.post(url, :body => escape_query(params))

      Authy::User.new(response)
    end

    # options:
    # :id user id
    # :token authy token entered by the user
    # :force (true|false) force to check even if the cellphone is not confirmed
    #
    def self.verify(params)
      token = params.delete(:token) || params.delete('token')
      user_id = params.delete(:id) || params.delete('id')
      params[:force] = true if params[:force].nil? && params['force'].nil?

      url = "#{Authy.api_uri}/protected/json/verify/#{escape_for_url(token)}/#{escape_for_url(user_id)}"
      response = http_client.get(url, {:api_key => Authy.api_key}.merge(params))

      Authy::Response.new(response)
    end

    # options:
    # :id user id
    # :force force sms
    def self.request_sms(params)
      user_id = params.delete(:id) || params.delete('id')

      url = "#{Authy.api_uri}/protected/json/sms/#{escape_for_url(user_id)}"
      response = http_client.get(url, {:api_key => Authy.api_key}.merge(params))

      Authy::Response.new(response)
    end

    # options:
    # :id user id
    # :force force phone_call
    def self.request_phone_call(params)
      user_id = params.delete(:id) || params.delete('id')

      url = "#{Authy.api_uri}/protected/json/call/#{escape_for_url(user_id)}"
      response = http_client.get(url, {:api_key => Authy.api_key}.merge(params))

      Authy::Response.new(response)
    end

    # options:
    # :id user id
    def self.delete_user(params)
      user_id = params.delete(:id) || params.delete('id')

      url = "#{Authy.api_uri}/protected/json/users/delete/#{escape_for_url(user_id)}"
      response = http_client.post(url, {:api_key => Authy.api_key}.merge(params))

      Authy::Response.new(response)
    end
  end
end

