# frozen_string_literal: true

require('rails_helper')

describe Api::TransactionsApi do
  let!(:merchant) do
    create(
      :merchant,
      id: 123,
      total_transaction_sum: 10,
      email: 'merchant1@mail.com',
      password: '123456',
      password_confirmation: '123456'
    )
  end
  let(:current_time) { Time.utc(2016, 8, 1, 13, 30) }
  let(:secret_key) { Rails.application.secrets.secret_key_base.to_s }

  before do
    SecureRandom.stubs(:uuid).returns('123456')
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
      it 'returns 422 status' do
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
    let(:token) { MerchantApiAuth::TokenCreator.token(merchant.id) }
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
        it 'returns authtorized' do
          expect(response.status).to(eq(401))
        end
        it 'returns error' do
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
        let!(:merchant) do
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
    context 'PaymentTransaction' do
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
      shared_examples 'returns 422 status' do
        it do
          http_request
          expect(response.status).to(eq(422))
        end
      end
      shared_examples 'returns 404 status' do
        it do
          http_request
          expect(response.status).to(eq(404))
        end
      end
      shared_examples 'returns 201 status' do
        it do
          http_request
          expect(response.status).to(eq(201))
        end
      end
      shared_examples 'not creates new transaction' do |transaction_scope|
        it do
          expect { http_request }
            .to_not(change { transaction_scope.reload.count })
        end
      end
      shared_examples 'creates new transaction' do |transaction_scope|
        it do
          expect { http_request }
            .to(change { transaction_scope.reload.count }.by(1))
        end
      end
      shared_examples "to not change merchant's total_transaction_sum" do
        it do
          expect { http_request }
            .to_not(change { merchant.reload.total_transaction_sum })
        end
      end
      shared_examples 'to not change AuthorizeTransaction status' do
        it do
          expect { http_request }
            .to_not(change { authorize_transaction.reload.status })
        end
      end
      shared_examples 'to not change ChargeTransaction status' do
        it do
          expect { http_request }
            .to_not(change { charge_transaction.reload.status })
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
        it_behaves_like 'returns 422 status'
        it 'return errors' do
          http_request
          expect(json).to(eql({ 'error' => 'transaction[type] does not have a valid value' }))
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
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'creates new transaction', AuthorizeTransaction.approved
          it_behaves_like 'returns 201 status'
          it 'return new transaction info' do
            http_request
            expect(json).to(eql({ 'transaction' => {
                                  'uuid' => '123456',
                                  'type' => 'AuthorizeTransaction',
                                  'status' => 'approved',
                                  'amount' => 10,
                                  'customer_email' => 'e@mail.com',
                                  'merchant_email' => 'merchant1@mail.com'
                                } }))
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
          it_behaves_like 'returns 422 status'
          it_behaves_like 'creates new transaction', AuthorizeTransaction.all
          it 'return errors' do
            http_request
            expect(json).to(eql({
                                  'transaction' =>
                                              {
                                                'uuid' => '123456',
                                                'type' => 'AuthorizeTransaction',
                                                'status' => 'error',
                                                'amount' => -10,
                                                'customer_email' => 'emailcom',
                                                'merchant_email' => 'merchant1@mail.com'
                                              },
                                  'error' => 'Customer email has incorrect email format, Amount must be greater than 0'
                                }))
          end
        end
      end
      context 'ChargeTransaction' do
        let(:authorize_transaction) do
          create(
            :authorize_transaction,
            uuid: 'auth123',
            amount: 10.0,
            merchant: merchant,
            customer_phone: '123456',
            customer_email: 'cust@mail.com'
          )
        end
        context 'all parameters valid' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'auth123',
                     type: 'ChargeTransaction',
                     amount: 5
                   }
                 }
          end
          before do
            authorize_transaction
          end
          it 'add amount to merchant' do
            expect { http_request }
              .to(change { merchant.reload.total_transaction_sum }.by(5))
          end
          it_behaves_like 'to not change AuthorizeTransaction status'
          it_behaves_like 'creates new transaction', ChargeTransaction.approved
          it_behaves_like 'returns 201 status'
          it 'return new transaction info' do
            http_request
            expect(json).to(eql({ 'transaction' =>
              {
                'uuid' => '123456',
                'type' => 'ChargeTransaction',
                'status' => 'approved',
                'amount' => 5,
                'customer_email' => 'cust@mail.com',
                'customer_phone' => '123456',
                'merchant_email' => 'merchant1@mail.com'
              } }))
          end
          context 'with not using parameters' do
            subject(:http_request) do
              post url,
                   params: {
                     token: token,
                     transaction: {
                       uuid: 'auth123',
                       type: 'ChargeTransaction',
                       amount: 5,
                       customer_phone: '+797897998',
                       customer_email: 'some_email@mail.com'
                     }
                   }
            end
            it_behaves_like 'returns 201 status'
            it 'ignore not using parameters' do
              http_request
              expect(json).to(eql({ 'transaction' =>
                {
                  'uuid' => '123456',
                  'type' => 'ChargeTransaction',
                  'status' => 'approved',
                  'amount' => 5,
                  'customer_email' => 'cust@mail.com',
                  'customer_phone' => '123456',
                  'merchant_email' => 'merchant1@mail.com'
                } }))
            end
          end
        end
        context 'not present uuid' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'not_present',
                     type: 'ChargeTransaction',
                     amount: -10
                   }
                 }
          end
          before do
            authorize_transaction
          end
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 404 status'
          it_behaves_like 'not creates new transaction', ChargeTransaction.all
          it 'return error message' do
            http_request
            expect(json).to(eql({ 'error' => 'record not present' }))
          end
        end
        context 'already reversed authorize_transaction' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'auth123',
                     type: 'ChargeTransaction',
                     amount: 5
                   }
                 }
          end
          before do
            authorize_transaction.reverse!
          end
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 422 status'
          it_behaves_like 'creates new transaction', ChargeTransaction.all
          it 'return transaction with error' do
            http_request
            expect(json).to(eql({
                                  'transaction' =>
                                                {
                                                  'uuid' => '123456',
                                                  'type' => 'ChargeTransaction',
                                                  'status' => 'error',
                                                  'amount' => 5,
                                                  'customer_email' => 'cust@mail.com',
                                                  'customer_phone' => '123456',
                                                  'merchant_email' => 'merchant1@mail.com'
                                                },
                                  'error' => 'Authorize transaction status of parent transaction should be approved'
                                }))
          end
        end
        context "total > authorize transaction's amount" do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'auth123',
                     type: 'ChargeTransaction',
                     amount: 100
                   }
                 }
          end
          before do
            authorize_transaction
          end
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 422 status'
          it_behaves_like 'creates new transaction', ChargeTransaction.all
          it 'return errors' do
            http_request
            expect(json)
              .to(eql({
                        'transaction' =>
                                      {
                                        'uuid' => '123456',
                                        'type' => 'ChargeTransaction',
                                        'status' => 'error',
                                        'amount' => 100,
                                        'customer_email' => 'cust@mail.com',
                                        'customer_phone' => '123456',
                                        'merchant_email' => 'merchant1@mail.com'
                                      },
                        'error' => 'Amount sum of change should be less than or equal to users blocked amount = 10'
                      }))
          end
        end
        context 'invalid instance' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'auth123',
                     type: 'ChargeTransaction',
                     amount: -10
                   }
                 }
          end
          before do
            authorize_transaction
          end
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 422 status'
          it_behaves_like 'creates new transaction', ChargeTransaction.all
          it 'return errors' do
            http_request
            expect(json).to(eql({
                                  'transaction' =>
                                    {
                                      'uuid' => '123456',
                                      'type' => 'ChargeTransaction',
                                      'status' => 'error',
                                      'amount' => -10,
                                      'customer_email' => 'cust@mail.com',
                                      'customer_phone' => '123456',
                                      'merchant_email' => 'merchant1@mail.com'
                                    },
                                  'error' => 'Amount must be greater than 0'
                                }))
          end
        end
      end
      context 'ReversalTransaction' do
        let(:authorize_transaction) do
          create(
            :authorize_transaction,
            uuid: 'auth123',
            amount: 10.0,
            merchant: merchant,
            customer_phone: '123456',
            customer_email: 'cust@mail.com'
          )
        end
        context 'all parameters valid' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'auth123',
                     type: 'ReversalTransaction'
                   }
                 }
          end
          before do
            authorize_transaction
          end
          it 'change AuthorizeTransaction status to reversed' do
            expect { http_request }
              .to(change { authorize_transaction.reload.status }.from(:approved).to(:reversed))
          end
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'creates new transaction', ReversalTransaction.approved
          it_behaves_like 'returns 201 status'
          it 'return new transaction info' do
            http_request
            expect(json).to(eql({ 'transaction' =>
              {
                'uuid' => '123456',
                'type' => 'ReversalTransaction',
                'status' => 'approved',
                'customer_email' => 'cust@mail.com',
                'customer_phone' => '123456',
                'merchant_email' => 'merchant1@mail.com'
              } }))
          end
          context 'with not using parameters' do
            subject(:http_request) do
              post url,
                   params: {
                     token: token,
                     transaction: {
                       uuid: 'auth123',
                       type: 'ReversalTransaction',
                       customer_phone: '+797897998',
                       customer_email: 'notValidEmail',
                       amount: 100_000_000
                     }
                   }
            end
            it_behaves_like 'returns 201 status'
            it 'ignore not using parameters' do
              http_request
              expect(json).to(eql({ 'transaction' =>
                {
                  'uuid' => '123456',
                  'type' => 'ReversalTransaction',
                  'status' => 'approved',
                  'customer_email' => 'cust@mail.com',
                  'customer_phone' => '123456',
                  'merchant_email' => 'merchant1@mail.com'
                } }))
            end
          end
        end
        context 'not present uuid' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'not_present',
                     type: 'ReversalTransaction'
                   }
                 }
          end
          before do
            authorize_transaction
          end
          it_behaves_like 'to not change AuthorizeTransaction status'
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 404 status'
          it_behaves_like 'not creates new transaction', ReversalTransaction.all
          it 'return error message' do
            http_request
            expect(json).to(eql({ 'error' => 'record not present' }))
          end
        end
        context 'already reversed authorize_transaction' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'auth123',
                     type: 'ReversalTransaction'
                   }
                 }
          end
          before do
            authorize_transaction.reverse!
          end
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 422 status'
          it_behaves_like 'creates new transaction', ReversalTransaction.all
          it 'return error message' do
            http_request
            expect(json).to(eql({
                                  'transaction' =>
                                                {
                                                  'uuid' => '123456',
                                                  'type' => 'ReversalTransaction',
                                                  'status' => 'error',
                                                  'customer_email' => 'cust@mail.com',
                                                  'customer_phone' => '123456',
                                                  'merchant_email' => 'merchant1@mail.com'
                                                },
                                  'error' => 'Authorize transaction status of parent transaction should be approved'
                                }))
          end
        end
      end
      context 'RefundTransaction' do
        let(:authorize_transaction) do
          create(
            :authorize_transaction,
            uuid: 'auth123',
            amount: 10.0,
            merchant: merchant,
            customer_phone: '123456',
            customer_email: 'cust@mail.com'
          )
        end
        let(:charge_transaction) do
          create(
            :charge_transaction,
            authorize_transaction: authorize_transaction,
            uuid: 'charge123',
            amount: 10.0,
            merchant: merchant,
            customer_phone: '123456',
            customer_email: 'cust@mail.com'
          )
        end
        context 'all parameters valid' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'charge123',
                     type: 'RefundTransaction',
                     amount: 10
                   }
                 }
          end
          before do
            charge_transaction
          end
          it 'remove amount from merchant' do
            expect { http_request }
              .to(change { merchant.reload.total_transaction_sum }.by(-10))
          end
          it 'changes charge_transaction status' do
            expect { http_request }
              .to(change { charge_transaction.reload.status }.from(:approved).to(:refunded))
          end
          it_behaves_like 'to not change AuthorizeTransaction status'
          it_behaves_like 'creates new transaction', RefundTransaction.approved
          it_behaves_like 'returns 201 status'
          it 'return new transaction info' do
            http_request
            expect(json).to(eql({ 'transaction' =>
              {
                'uuid' => '123456',
                'type' => 'RefundTransaction',
                'status' => 'approved',
                'amount' => 10,
                'customer_email' => 'cust@mail.com',
                'customer_phone' => '123456',
                'merchant_email' => 'merchant1@mail.com'
              } }))
          end
          context 'with not using parameters' do
            subject(:http_request) do
              post url,
                   params: {
                     token: token,
                     transaction: {
                       uuid: 'charge123',
                       type: 'RefundTransaction',
                       amount: 10,
                       customer_phone: '+797897998',
                       customer_email: 'some_email@mail.com'
                     }
                   }
            end
            it_behaves_like 'returns 201 status'
            it 'ignore not using parameters' do
              http_request
              expect(json).to(eql({ 'transaction' =>
                {
                  'uuid' => '123456',
                  'type' => 'RefundTransaction',
                  'status' => 'approved',
                  'amount' => 10,
                  'customer_email' => 'cust@mail.com',
                  'customer_phone' => '123456',
                  'merchant_email' => 'merchant1@mail.com'
                } }))
            end
          end
        end
        context 'not present uuid' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'not_present',
                     type: 'RefundTransaction',
                     amount: -10
                   }
                 }
          end
          before do
            charge_transaction
          end
          it_behaves_like 'to not change ChargeTransaction status'
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 404 status'
          it_behaves_like 'not creates new transaction', RefundTransaction.all
          it 'return error message' do
            http_request
            expect(json).to(eql({ 'error' => 'record not present' }))
          end
        end
        context 'already refunded charge_transaction' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'charge123',
                     type: 'RefundTransaction',
                     amount: 10
                   }
                 }
          end
          before do
            charge_transaction.refund!
          end
          it_behaves_like 'to not change ChargeTransaction status'
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 422 status'
          it_behaves_like 'creates new transaction', RefundTransaction.all
          it 'return error message' do
            http_request
            expect(json).to(eql({
                                  'transaction' =>
                                                {
                                                  'uuid' => '123456',
                                                  'type' => 'RefundTransaction',
                                                  'status' => 'error',
                                                  'amount' => 10,
                                                  'customer_email' => 'cust@mail.com',
                                                  'customer_phone' => '123456',
                                                  'merchant_email' => 'merchant1@mail.com'
                                                },
                                  'error' => 'Charge transaction status of parent transaction should be approved'
                                }))
          end
        end
        context 'amount != charge transaction amount' do
          subject(:http_request) do
            post url,
                 params: {
                   token: token,
                   transaction: {
                     uuid: 'charge123',
                     type: 'RefundTransaction',
                     amount: 15
                   }
                 }
          end
          before do
            charge_transaction
          end
          it_behaves_like 'to not change ChargeTransaction status'
          it_behaves_like "to not change merchant's total_transaction_sum"
          it_behaves_like 'returns 422 status'
          it_behaves_like 'creates new transaction', RefundTransaction.all
          it 'return errors' do
            http_request
            expect(json)
              .to(eql({
                        'transaction' =>
                                        {
                                          'uuid' => '123456',
                                          'type' => 'RefundTransaction',
                                          'status' => 'error',
                                          'amount' => 15,
                                          'customer_email' => 'cust@mail.com',
                                          'customer_phone' => '123456',
                                          'merchant_email' => 'merchant1@mail.com'
                                        },
                        'error' => 'Amount amount should be equal to change transaction amount = 10'
                      }))
          end
        end
      end
    end
  end
end
