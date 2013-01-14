module Authy
  #
  #  Authy.api_key = 'foo'
  #  Authy.api_uri = 'http://test-authy-api.heroku.com/'
  #
  class API
    include Typhoeus

    def self.register_user(attributes)
      api_key = attributes.delete(:api_key)
      params = {
        :user => attributes,
        :api_key => api_key || Authy.api_key
      }

      url = "#{Authy.api_uri}/protected/json/users/new"
      response = Typhoeus::Request.post(url, :params => params)

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

      url = "#{Authy.api_uri}/protected/json/verify/#{escape_for_url(token)}/#{escape_for_url(user_id)}"
      response = Typhoeus::Request.get(url, :params => {:api_key => Authy.api_key}.merge(params))

      Authy::Response.new(response)
    end

    # options:
    # :id user id
    # :force force sms
    def self.request_sms(params)
      user_id = params.delete(:id) || params.delete('id')

      url = "#{Authy.api_uri}/protected/json/sms/#{escape_for_url(user_id)}"
      response = Typhoeus::Request.get(url, :params => {:api_key => Authy.api_key}.merge(params))

      Authy::Response.new(response)
    end

    private
    def self.escape_for_url(field)
      URI.escape(field.to_s.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end
  end
end
