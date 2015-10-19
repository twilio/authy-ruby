module Authy
  class OneTouch < Authy::API

    # Maximum String size for the parameters
    MAX_STRING_SIZE = 200

    # options:
    #   :id
    #   :details Hash containing the approval request details
    #   :hidden_details
    #   :phone_number The persons phone number.
    def self.send_approval_request(params)
      user_id           = params.delete(:id) || params.delete('id')
      message           = (params.delete(:message) || params.delete('message')).to_s
      details           = params.delete(:details) || params.delete('details')
      hidden_details    = params.delete(:hidden_details) || params.delete('hidden_details')
      logos             = params.delete(:logos) || params.delete('logos')
      seconds_to_expire = params.delete(:seconds_to_expire) || params.delete('seconds_to_expire')

      return invalid_response("message cannot be blank") if message.empty?
      return invalid_response('user id is invalid') unless is_digit?(user_id)

      begin
        self.clean_hash!(details)
        self.clean_hash!(hidden_details)
        self.clean_logos!(logos)
      rescue => e
        return invalid_response("Invalid parameters: #{e.message}")
      end

      post_request("onetouch/json/users/#{user_id}/approval_requests", {
        message: message[0, MAX_STRING_SIZE],
        details: details,
        hidden_details: hidden_details,
        logos: logos,
        seconds_to_expire: seconds_to_expire
      })
    end

    def self.approval_request_status(params)
      uuid = params.delete(:uuid) || params.delete('uuid')

      get_request("onetouch/json/approval_requests/#{uuid}")
    end

  private
    def self.clean_hash!(test_hash)
      return if test_hash.nil? # Allow nil hash

      raise "Hash expected. Got: #{test_hash.class}" unless test_hash.is_a? Hash
      test_hash = test_hash.map { |k, v| [k, v.to_s] }.to_h
    end

    def self.clean_logos!(logos)
      return if logos.nil? # Allow nil logos

      raise "Array expected. Got #{logos.class}" unless logos.is_a? Array
      logos = logos.map do |logo|
        raise "Invalid logo format: #{logo}" unless logo.is_a? Hash
        res = logo.delete(:res) || logo.delete('res')
        url = logo.delete(:url) || logo.delete('url')

        raise "Logo should include res and url" if res.nil? || url.nil?

        # We ignore any additional parameter on the logos, and truncate
        # string size to the maximum allowed.
        { res: res[0, MAX_STRING_SIZE], url: url[0, MAS_STRING_SIZE] }
      end
    end
  end
end
