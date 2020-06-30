class MerchantApiAuth::TokenCreator < MerchantApiAuth::Base
  ACTIVITY_PERIOD = 4.hours

  attr_reader :resource_id

  def self.token(resource_id)
    new(resource_id).token
  end

  def initialize(resource_id)
    @resource_id = resource_id
  end

  def token
    JWT.encode(payload, secret_key, 'HS256')
  end

  private

  def payload
    {resource_id: resource_id, 
     expires_in: (Time.now + ACTIVITY_PERIOD).to_i}
  end
end
