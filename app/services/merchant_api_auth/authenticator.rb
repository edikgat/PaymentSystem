# frozen_string_literal: true

module MerchantApiAuth
  class Authenticator < Base
    attr_reader :token

    def initialize(token)
      @token = token
    end

    def resource
      @resource ||=
        begin
             if Time.now < expires_in
               resource_scope.find(resource_id)
             else
               false
             end
        rescue JWT::DecodeError, NameError, TypeError, ActiveRecord::RecordNotFound
          false
           end
    end

    private

    def payload
      @payload ||= JWT.decode(token, secret_key, 'HS256')[0]
    end

    def resource_scope
      Merchant.active
    end

    def resource_id
      payload['resource_id']
    end

    def expires_in
      Time.at(payload['expires_in'])
    end
  end
end
