module Authy
  module URL
    def self.included receiver
      receiver.extend ClassMethods
    end

    module ClassMethods
      def escape_for_url(field)
        URI.escape(field.to_s.strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      end

      # Copied and extended from httpclient's HTTP::Message#escape_query()
      def escape_query(query, namespace = nil) # :nodoc:
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
end
