# frozen_string_literal: true

class Api::TransactionsApi < Grape::API
  version 'v1', using: :path
  prefix 'api'

  before do
    authenticate_merchant!
  end

  helpers do
    def current_merchant
      @merchant
    end

    def authenticate_merchant!
      token = params['token'] || request.headers['Authorization']&.split(' ').last
      authenticator = MerchantApiAuth::Authenticator.new(token)
      if authenticator.resource
        @merchant = authenticator.resource
      else
        error!('Unauthorized', 401)
      end
    end
  end

  resource :transaction do
    desc 'Submitting Transactions'
    params do
      optional :token, type: String, desc: 'JWT tocket should be here or at Authtorization header'
      requires :transaction, type: Hash do
        requires :type, type: Symbol, values: PaymentTransaction::TYPES
        optional :uuid, type: String
        optional :amount, type: BigDecimal
      end
    end
    post do
      present current_merchant.payment_transactions.last, with: PaymentTransactionPresenter
    end
  end
end
