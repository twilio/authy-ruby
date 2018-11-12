require 'logger'
require 'authy/e164_adapter'

module Authy
  AUTHY_LOGGER = Logger.new(STDOUT)
  #
  #  Authy.api_key = 'foo'
  #  Authy.api_uri = 'http://test-authy-api.heroku.com/'
  #
  class API
    USER_AGENT = "AuthyRuby/#{Authy::VERSION} (#{RUBY_PLATFORM}, Ruby #{RUBY_VERSION})"
    MIN_TOKEN_SIZE = 6
    MAX_TOKEN_SIZE = 12

    include ::Phony
    include Authy::URL
    Hash.include Authy::E164Adapter::HashAttributeAdapter

    extend HTTPClient::IncludeClient
    include_http_client(agent_name: USER_AGENT)

    def self.register_user(attributes)
      api_key = attributes.delete(:api_key) || Authy.api_key
      send_install_link_via_sms = attributes.delete(:send_install_link_via_sms) { true }
      attributes.adapt!
      
      params = {
        :user => attributes,
        :send_install_link_via_sms => send_install_link_via_sms
      }

      url = "#{Authy.api_uri}/protected/json/users/new"
      response = http_client.post(url, :body => escape_query(params), :header => default_header(api_key: api_key))

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

      return invalid_response('Token format is invalid') unless token_is_safe?(token)
      return invalid_response('User id is invalid') unless is_digit?(user_id)

      params[:force] = true if params[:force].nil? && params['force'].nil?

      response = get_request("protected/json/verify/:token/:user_id", params.merge({
          "token" => token,
          "user_id" => user_id
        })
      )

      return verify_response(response) if response.ok?
      return response
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
    # :qr_size qr size
    # :qr_label context for qr code
    def self.request_qr_code(params)
      user_id = params.delete(:id) || params.delete('id')
      qr_size = params.delete(:qr_size) || params.delete('qr_size') || 300
      qr_label = params.delete(:qr_label) || params.delete('qr_label') || ""

      return invalid_response('User id is invalid') unless is_digit?(user_id)
      return invalid_response('Qr image size is invalid') unless is_digit?(qr_size)

      response = post_request("protected/json/users/:user_id/secret" ,params.merge({
        "user_id" => user_id,
        "qr_size" => qr_size,
        "label" => qr_label
      }))
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
      header_ = default_header(params: params)

      uri_params = keys_to_verify(uri, params)
      state, error = validate_for_url(uri_params, params)

      response = if state
                   url = "#{Authy.api_uri}/#{eval_uri(uri, params)}"
                   params = clean_uri_params(uri_params, params)
                   http_client.post(url, :body => escape_query(params), header: header_)
                 else
                   build_error_response(error)
                 end
      Authy::Response.new(response)
    end

    def self.get_request(uri, params = {})
      header_ = default_header(params: params)

      uri_params = keys_to_verify(uri, params)
      state, error = validate_for_url(uri_params, params)
      response = if state
                   url = "#{Authy.api_uri}/#{eval_uri(uri, params)}"
                   params = clean_uri_params(uri_params, params)
                   http_client.get(url, params, header_)
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

    def self.token_is_safe?(token)
      !!(/\A\d{#{MIN_TOKEN_SIZE},#{MAX_TOKEN_SIZE}}\Z/.match token)
    end

    def self.is_digit?(str)
      !!(/^\d+$/.match str.to_s)
    end

    def self.invalid_response(str="Invalid resonse")
      response = build_error_response(str)
      return Authy::Response.new(response)
    end

    def self.verify_response(response)
      return response if response['token'] == 'is valid'
      response = build_error_response('Token is invalid')
      return Authy::Response.new(response)
    end

    def self.default_header(api_key: nil, params: {})
      header = {
        "X-Authy-API-Key" => api_key || Authy.api_key
      }

      api_key_ = params.delete(:api_key) || params.delete("api_key")

      if api_key_ && api_key_.strip != ""
        AUTHY_LOGGER.warn("[DEPRECATED]: The Authy API key should not be sent as a parameter. Please send the HTTP header 'X-Authy-API-Key' instead.")
        header["X-Authy-API-Key"] = api_key_
      end

      return header
    end

  end
end
