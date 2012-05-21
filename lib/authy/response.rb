module Authy
  class Response < Hash
    attr_reader :raw_response
    def initialize(response)
      @raw_response = response
      parse_body
    end

    def id
      self["id"]
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
      (@raw_response.curl_error_message == "No error" && self.empty?) ? self.body : @raw_response.curl_error_message
    end

    def errors
      self['errors'] || {}
    end

    protected
    def method_missing(name, *args, &block)
      if self.include?(name.to_s)
        self[name.to_s]
      else
        super(name, *args, &block)
      end
    end

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
