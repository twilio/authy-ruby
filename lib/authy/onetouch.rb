module Authy
  class OneTouch < Authy::API

    # options:
    #   :id
    #   :details Hash containing the approval request details
    #   :hidden_details
    #   :phone_number The persons phone number.
    def self.send_approval_request(params)
      user_id =        params.delete(:id) || params.delete('id')
      message =        (params.delete(:message) || params.delete('message')).to_s
      details =        params.delete(:details) || params.delete('details')
      hidden_details = params.delete(:hidden_details) || params.delete('hidden_details')
      logos =          params.delete(:logos) || params.delete('logos')

      return invalid_response("Message cannot be blank") if message.empty?
      return invalid_response('User id is invalid') unless is_digit?(user_id)

      begin
        self.clean_hash!(details)
        self.clean_hash!(hidden_details)
      rescue => e
        return invalid_response("Invalid details or hidden details: #{e.message}")
      end

      post_request("onetouch/json/users/#{user_id}/approval_requests", {
        message: message,
        details: details,
        hidden_details: hidden_details,
        logos: logos
      })
    end

    def self.approval_request_status(params)
      uuid = params.delete(:uuid) || params.delete('uuid')

      get_request("onetouch/json/approval_requests/#{uuid}")
    end

  private
    def self.clean_hash!(test_hash)
      raise "Hash expected. Got: #{test_hash.class}" unless test_hash.is_a? Hash
      test_hash = test_hash.map { |k, v| [k, v.to_s] }.to_h
    end
  end
end
