class MerchantApiAuth::Base
  private

  def secret_key
    Rails.application.secrets.secret_key_base.to_s
  end
end
