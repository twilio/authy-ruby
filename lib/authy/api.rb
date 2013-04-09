module Authy
  #
  #  Authy.api_key = 'foo'
  #  Authy.api_uri = 'http://test-authy-api.heroku.com/'
  #
  class API
    USER_AGENT = "authy-ruby"

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

    private
    def self.escape_for_url(field)
      URI.escape(field.to_s.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end


    def Array.try_convert(value)
      return value if value.instance_of?(Array)
      return nil if !value.respond_to?(:to_ary)
      converted = value.to_ary
      return converted if converted.instance_of?(Array)

      cname = value.class.name
      raise TypeError, "can't convert %s to %s (%s#%s gives %s)" %
        [cname, Array.name, cname, :to_ary, converted.class.name]
    end unless Array.respond_to?(:try_convert)
    
    # Copied and extended from httpclient's HTTP::Message#escape_query()
    def self.escape_query(query, namespace = nil) # :nodoc:
      pairs = []
      query.each { |attr, value|
        left = namespace ? "#{namespace}[#{attr.to_s}]" : attr.to_s
        if values = Array.try_convert(value)
          values.each { |value|
            if value.respond_to?(:read)
              value = value.read
            end

            if value.kind_of?(Hash)
              pairs.push(escape_query(value, left+"[]"))
            else
              pairs.push(HTTP::Message.escape(left+ '[]') << '=' << HTTP::Message.escape(value.to_s))
            end
          }
        elsif values = Hash.try_convert(value)
          pairs.push(escape_query(values, left.dup))
        else
          if value.respond_to?(:read)
            value = value.read
          end
          pairs.push(HTTP::Message.escape(left) << '=' << HTTP::Message.escape(value.to_s))
        end
      }
      pairs.join('&')
    end
  end
end
