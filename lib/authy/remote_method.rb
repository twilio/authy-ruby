module Authy
  module RemoteMethod
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def define_remote_method(name, opts = {})
        super(name, opts)

        raw_method = :"raw_#{name}"

        req_params = opts[:required]
        remote_method = @remote_methods[name]

        instance_eval do
          alias :"#{raw_method}" :"#{name}"
        end

        class << self; self; end.instance_eval do
          self.send(:define_method, name) do |*opts|
            opts = opts.last || {}

            if remote_method.http_method.to_s == 'post'
              body = {:api_key => Authy.api_key}

              add_required_params(name, body, opts, req_params)

              opts[:body] = body.to_json
            else
              (opts[:params] ||= {}).merge!({:api_key => Authy.api_key})

              add_required_params(name, opts[:params], opts, req_params)
            end

            opts[:headers] = {'Content-Type' => 'application/json'}
            send(raw_method, opts)
          end
        end

        def add_required_params(name, target, params, required_params)
          required_params.each do |rp|
            if !params.include?(rp)
              args = required_params.map {|p| ":#{p} => value" }.join(", ")
              raise ArgumentError, "#{required_params.inspect} params are required. use #{name}(#{args}, ...)"
            end
            target[rp] = params.delete(rp)
          end
        end
      end
    end
  end
end
