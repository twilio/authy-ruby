module Authy
  class User < Authy::Response
    def id
      self['id']
    end

    protected
    def parse_body
      begin
        body = JSON.parse(@raw_response.body)
        body = body['user'] if body['user']

        body.each do |k,v|
          self[k] = v
        end
      rescue Exception => e
      end
    end
  end
end