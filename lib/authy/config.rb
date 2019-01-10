module Authy
  class << self
    def api_key=(key)
      @api_key = key
    end

    def api_key
      @api_key || ENV["AUTHY_API_KEY"]
    end

    def api_uri=(uri)
      @api_uri = uri
    end
    alias :api_url= :api_uri=

    def api_uri
      @api_uri || "https://api.authy.com"
    end
    alias :api_url :api_uri

    def user_agent
      @user_agent || "AuthyRuby/#{Authy::VERSION} (#{RUBY_PLATFORM}, Ruby #{RUBY_VERSION})"
    end

    def user_agent=(user_agent)
      @user_agent = user_agent
    end
  end
end
