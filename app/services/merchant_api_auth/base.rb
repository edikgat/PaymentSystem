# frozen_string_literal: true

module MerchantApiAuth
  class Base
    private

    def secret_key
      Rails.application.secrets.secret_key_base.to_s
    end
  end
end
