module Authy
  class Response < Hash
    attr_reader :raw_response
    def initialize(response)
      @raw_response = response
      @errors = {}
      parse_body
    end

    def id
      self["id"]
    end

    def ok?
      @raw_response.status == 200
    end
    alias :success? :ok?

    def body
      @raw_response.body
    end

    def code
      @raw_response.status
    end

    def error_msg
      if ok?
        "No error"
      elsif self.empty?
        self.body
      else
        self["message"] || "No error"
      end
    end
    alias :message :error_msg

    def errors
      self["errors"] || @errors
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
      body = JSON.parse(@raw_response.body) rescue {}
      body.each do |k,v|
        self[k] = v
      end
    end
  end
end
