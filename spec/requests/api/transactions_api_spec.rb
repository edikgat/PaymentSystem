# frozen_string_literal: true

require('rails_helper')

describe Api::TransactionsApi do
  let!(:resource) do
    create(
      :merchant,
      id: 123,
      email: 'merchant1@mail.com',
      password: '123456',
      password_confirmation: '123456'
    )
  end
  let(:current_time) { Time.utc(2016, 8, 1, 13, 30) }
  let(:secret_key) { Rails.application.secrets.secret_key_base.to_s }

  before do
    Timecop.freeze(current_time)
  end

  describe 'POST /api/v1/token' do
    let(:url) { '/api/v1/token' }
    context 'correct email & password' do
      before do
        post url,
             params: {
               merchant: { email: 'merchant1@mail.com', password: '123456' }
             }
      end
      it 'should create JWT token' do
        expect(response.status).to(eq(201))
        expect(json).to(eql({ 'jwt' => 'eyJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJ'\
          'jZV9pZCI6MTIzLCJleHBpcmVzX2luIjoxNDcwMDcyNjAwfQ.Fidjndd1ldwZ'\
          'N0nVB-RvycHsmmO7x0N98Di67r7DY_I' }))
      end
      it 'JWT token contain correct payload' do
        expect(JWT.decode(json['jwt'], secret_key, 'HS256')).to(eql([
          { 'expires_in' => 1_470_072_600, 'resource_id' => 123 },
          { 'alg' => 'HS256' }
        ]))
      end
      context 'xml' do
        let(:url) { '/api/v1/token.xml' }
        it 'should create JWT token' do
          expect(response.status).to(eq(201))
          expect(xml_hash).to(eql({ 'jwt' => 'eyJhbGciOiJIUzI1NiJ9.eyJyZXNvdXJ'\
            'jZV9pZCI6MTIzLCJleHBpcmVzX2luIjoxNDcwMDcyNjAwfQ.Fidjndd1ldwZ'\
            'N0nVB-RvycHsmmO7x0N98Di67r7DY_I' }))
        end
      end
    end

    context 'incorrect email or password' do
      before do
        post url,
             params: {
               merchant: { email: 'notPresentmerchant1@mail.com', password: '123456' }
             }
      end
      it 'return 422 status' do
        expect(response.status).to(eq(422))
      end
      it 'has error message' do
        expect(json).to(eql({ 'error' => 'invalid password or email' }))
      end
      context 'xml' do
        let(:url) { '/api/v1/token.xml' }
        it 'has error message' do
          expect(xml_hash).to(eql({ 'error' => 'invalid password or email' }))
        end
      end
    end
  end
  describe 'POST /api/v1/transaction' do
    let(:url) { '/api/v1/transaction' }
    let(:token) { MerchantApiAuth::TokenCreator.token(resource.id) }
    context 'authentication' do
      context 'correct token' do
        context 'in parameters hash' do
          before do
            post url,
                 params: {
                   token: token,
                   transaction: { type: 'AuthorizeTransaction', amount: 10, customer_email: 'e@mail.com' }
                 }
          end
          it 'access to api' do
            expect(response.status).to(eq(201))
          end
        end
        context 'at Authorization header' do
          before do
            post url,
                 headers: { 'Authorization' => "JWT #{token}" },
                 params: {
                   transaction: { type: 'AuthorizeTransaction', amount: 10, customer_email: 'e@mail.com' }
                 }
          end
          it 'access to api' do
            expect(response.status).to(eq(201))
          end
        end
      end
      shared_examples 'unauthorized' do
        it 'return authtorized' do
          expect(response.status).to(eq(401))
        end
        it 'return error' do
          expect(json).to(eq({ 'error' => 'Unauthorized' }))
        end
      end
      context 'incorrect token' do
        before do
          post url,
               params: {
                 token: 'incorrect',
                 transaction: { type: 'AuthorizeTransaction', amount: 10, customer_email: 'e@mail.com' }
               }
        end
        it_behaves_like 'unauthorized'
      end
      context 'expired token' do
        before do
          token
          Timecop.freeze(current_time + 5.hours)
          post url,
               params: {
                 token: token,
                 transaction: { type: 'AuthorizeTransaction', amount: 10, customer_email: 'e@mail.com' }
               }
        end
        it_behaves_like 'unauthorized'
      end
      context 'inactive merchant' do
        let!(:resource) do
          create(
            :merchant,
            id: 123,
            email: 'merchant1@mail.com',
            password: '123456',
            password_confirmation: '123456',
            status: :inactive
          )
        end
        before do
          post url,
               params: {
                 token: token,
                 transaction: { type: 'AuthorizeTransaction', amount: 10, customer_email: 'e@mail.com' }
               }
        end
        it_behaves_like 'unauthorized'
      end
    end
    context 'AuthorizeTransaction' do
      context 'all parameters valid' do
        subject(:http_request) do
          post url,
               params: {
                 token: token,
                 transaction: {
                   type: 'AuthorizeTransaction',
                   amount: 10,
                   customer_email: 'e@mail.com'
                 }
               }
        end
        it 'create new transaction' do
          expect { http_request }
            .to(change { AuthorizeTransaction.all.reload.count }.from(0).to(1))
        end
        it 'return 201 status' do
          http_request
          expect(response.status).to(eq(201))
        end
        it 'return new transaction info' do
          SecureRandom.stubs(:uuid).returns('123456')
          http_request
          expect(json).to(eql({
                                'uuid' => '123456',
                                'type' => 'AuthorizeTransaction',
                                'status' => 'approved',
                                'amount' => 10,
                                'customer_email' => 'e@mail.com',
                                'merchant_email' => 'merchant1@mail.com'
                              }))
        end
      end
      shared_examples 'invalid input' do
        it 'not create new transaction' do
          expect { http_request }
            .to_not(change { AuthorizeTransaction.all.reload.count })
        end
        it 'return 422 status' do
          http_request
          expect(response.status).to(eq(422))
        end
      end
      context 'invalid api parameters' do
        subject(:http_request) do
          post url,
               params: {
                 token: token,
                 transaction: {
                   type: 'invalid',
                   amount: -10,
                   customer_email: 'emailcom'
                 }
               }
        end
        it_behaves_like 'invalid input'
        it 'return errors' do
          http_request
          expect(json).to(eql({ "error" => "transaction[type] does not have a valid value" }))
        end
      end
      context 'invalid instance' do
        subject(:http_request) do
          post url,
               params: {
                 token: token,
                 transaction: {
                   type: 'AuthorizeTransaction',
                   amount: -10,
                   customer_email: 'emailcom'
                 }
               }
        end
        it_behaves_like 'invalid input'
        it 'return errors' do
          http_request
          expect(json).to(eql({ 'error' =>
            'Validation failed: Customer email has incorrect email format, Amount must be greater than 0' }))
        end
      end
    end
  end
end
