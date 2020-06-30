require 'rails_helper'

RSpec.describe MerchantApiAuth::Authenticator do
  subject(:authenticator) { described_class.new(token) }
  let(:token) { MerchantApiAuth::TokenCreator.token(resource.id) }
  let(:secret_key) { Rails.application.secrets.secret_key_base.to_s }
  let(:current_time) { Time.utc(2016, 8, 1, 13, 30) }
  let(:decoded_payload) { JWT.decode(token, secret_key, 'HS256') }
  let!(:resource) { create(:merchant, id: 123) }
  before do
    Timecop.freeze(current_time)
  end

  describe "#resource" do
    context 'token valid & resource present & not expires' do
      it 'return resource object' do
        expect(authenticator.resource).to eql(resource)
      end
    end
    context 'other resource' do
      let!(:resource) { create(:admin, id: 321) }
      it 'return resource object' do
        expect(authenticator.resource).to eql(false)
      end
    end
    context 'merchant inactive' do
      let!(:resource) { create(:merchant, id: 123, status: :inactive) }
      it 'return false' do
        expect(authenticator.resource).to eql(false)
      end
    end
    context 'token invalid' do
      let(:token) { 'invalid' }
      it 'return false' do
        expect(authenticator.resource).to eql(false)
      end
    end
    context 'resource removed' do
      before do
        token
        resource.destroy
      end
      it 'return false' do
        expect(authenticator.resource).to eql(false)
      end
    end
    context '+ 5 hours' do
      before do
        token
        Timecop.freeze(current_time + 5.hours)
      end
      it 'return false' do
        expect(authenticator.resource).to eql(false)
      end
    end
    context '+ 3 hours' do
      before do
        token
        Timecop.freeze(current_time + 3.hours)
      end
      it 'return resource' do
        expect(authenticator.resource).to eql(resource)
      end
    end
  end
end
