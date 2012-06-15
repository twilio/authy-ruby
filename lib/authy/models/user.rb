module Authy
  class User < Authy::Response
    def id
      self['id']
    end

    def errors
      case
      when self.ok?
        {}
      when !@errors.empty?
        @errors
      else
        {"error" => error_msg}
      end
    end

    protected
    def parse_body
      begin
        body = JSON.parse(@raw_response.body)
        body = body['user'] if body['user']

        if self.ok?
          body.each do |k,v|
            self[k] = v
          end
        else
          if body.has_key?('errors')
            @errors = body['errors']
          else
            @errors = body
          end
        end
      rescue Exception => e
      end
    end
  end
end
