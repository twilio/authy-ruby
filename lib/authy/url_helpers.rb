module Authy
  module URL
    def self.included receiver
      receiver.extend ClassMethods
    end

    module ClassMethods
      def keys_to_verify(uri, params)
        uri.scan(/:(\w+)/).flatten
      end

      def clean_uri_params(uri_params, params)
        params.reject { |k, v| uri_params.include? k}
      end

      def eval_uri(uri, params = {})
        uri.gsub(/:\w+/) {|s| params[s.gsub(":", "")]}
      end

      def validate_for_url(names, to_validate = {})
        names.each do |name|
          value = to_validate[name]
          if value.nil? or value.to_s.empty? or value.to_s.split(" ").size == 0
            puts "#{name} param is blank."
            return [ false, "#{name} is blank." ]
          end
        end
        [ true, ""]
      end
      
      def escape_for_url(field)
        URI.escape(field.to_s.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      end

      def to_param(left, right)
        HTTP::Message.escape(left) + '=' +  HTTP::Message.escape(right.to_s)
      end

      def params_from_array(left, values)
        values.map do |value|
          if value.respond_to?(:read)
            value = value.read
          end

          if value.kind_of?(Hash)
            escape_query(value, left+"[]")
          else
            to_param(left + '[]', value)
          end
        end
      end

      # Copied and extended from httpclient's HTTP::Message#escape_query()
      def escape_query(query, namespace = nil) # :nodoc:
        pairs = []

        query.each do |attr, value|
          left = namespace ? "#{namespace}[#{attr.to_s}]" : attr.to_s
          if values = Array.try_convert(value)
            pairs += params_from_array(left, values)
          elsif values = Hash.try_convert(value)
            pairs.push(escape_query(values, left.dup))
          else
            if value.respond_to?(:read)
              value = value.read
            end
            pairs.push(to_param(left, value))
          end
        end
        pairs.join('&')
      end
    end
  end
end
