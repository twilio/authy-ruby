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

      get_request("protected/json/verify/:token/:user_id", params.merge({
          "token" => token,
          "user_id" => user_id
        })
      )
    end

    # options:
    # :id user id
    # :force force sms
    def self.request_sms(params)
      user_id = params.delete(:id) || params.delete('id')

      get_request("protected/json/sms/:user_id", params.merge({"user_id" => user_id}))
    end

    # options:
    # :id user id
    # :force force phone_call
    def self.request_phone_call(params)
      user_id = params.delete(:id) || params.delete('id')

      get_request("protected/json/call/:user_id", params.merge({"user_id" => user_id}))
    end

    # options:
    # :id user id
    def self.delete_user(params)
      user_id = params.delete(:id) || params.delete('id')

      post_request("protected/json/users/delete/:user_id", params.merge({"user_id" =>user_id}))
    end

    def self.user_status(params)
      user_id = params.delete(:id) || params.delete("id")
      get_request("protected/json/users/:user_id/status", params.merge({"user_id" => user_id}))
    end

    private

    def self.post_request(uri, params = {})
      uri_params = keys_to_verify(uri, params)
      state, error = validate_for_url(uri_params, params)

      response = if state
                   url = "#{Authy.api_uri}/#{eval_uri(uri, params)}"
                   params = clean_uri_params(uri_params, params)
                   http_client.post(url, :body => escape_query({:api_key => Authy.api_key}.merge(params)))
                 else
                   build_error_response(error)
                 end
      Authy::Response.new(response)
    end

    def self.get_request(uri, params = {})
      uri_params = keys_to_verify(uri, params)
      state, error = validate_for_url(uri_params, params)
      response = if state
                   url = "#{Authy.api_uri}/#{eval_uri(uri, params)}"
                   params = clean_uri_params(uri_params, params)
                   http_client.get(url, escape_params({:api_key => Authy.api_key}.merge(params)))
                 else
                   build_error_response(error)
                 end
      Authy::Response.new(response)
    end

    def self.build_error_response(error = "blank uri param found")
      OpenStruct.new({
        'status' => 400,
        'body' => {
          'success' => false,
          'message' => error,
          'errors' => {
            'message' => error
          }
        }.to_json
      })
    end
  end
end
