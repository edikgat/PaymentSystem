# frozen_string_literal: true

require('rails_helper')

RSpec.describe(MerchantApiAuth::TokenCreator) do
  subject(:token) { described_class.token(123) }
  let(:secret_key) { Rails.application.secrets.secret_key_base.to_s }
  let(:current_time) { Time.utc(2016, 8, 1, 13, 30) }
  let(:decoded_payload) { JWT.decode(token, secret_key, 'HS256') }

  describe '#token' do
    before do
      Timecop.freeze(current_time)
    end

    it 'produce correct token' do
      expect(token).to(eql('eyJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJjZV9pZCI6MTIz' \
                           'LCJleHBpcmVzX2luIjoxNDcwMDcyNjAwfQ.Fidjndd1ld' \
                           'wZN0nVB-RvycHsmmO7x0N98Di67r7DY_I'))
    end

    it 'token has_correct payload' do
      expect(decoded_payload).to(eql([
        {
          'expires_in' => 1_470_072_600,
          'resource_id' => 123
        },
        { 'alg' => 'HS256' }
      ]))
    end

    it 'expires in 4 hours' do
      expect(Time.at(decoded_payload[0]['expires_in']) - current_time).to(eql(14_400.0))
    end
  end
end
