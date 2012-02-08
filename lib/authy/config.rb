module Authy
  def self.api_key=(key)
    @api_key = key

    self.remote_methods.each do |name, method|
      (method.options[:params] ||= {}).merge!({'api_key' => key})
    end
  end

  def self.api_key
    @api_key
  end

  def self.api_uri=(uri)
    @api_uri = uri

    self.remote_methods.each do |name, method|
      method.instance_variable_set("@base_uri", uri)
    end
  end

  def self.api_uri
    @api_uri
  end

  private
  def self.remote_methods
    Authy::API.instance_variable_get("@remote_methods")
  end
end
