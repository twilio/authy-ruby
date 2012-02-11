module Authy
  class Response < Hash
    attr_reader :raw_response
    def initialize(response)
      @raw_response = response
      parse_body
    end

    def ok?
      @raw_response.code == 200
    end

    def body
      @raw_response.body
    end

    def code
      @raw_response.code
    end

    def error_msg
      @raw_response.curl_error_message == "No error" ? self.body : @raw_response.curl_error_message
    end

    private
    def parse_body
      begin
        body = JSON.parse(@raw_response.body)
        body.each do |k,v|
          self[k] = v
        end
      rescue Exception => e
      end
    end
  end
end
