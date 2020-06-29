# frozen_string_literal: true

class Api::TransactionsApi < Grape::API
  version 'v1', using: :path
  prefix 'api'
  format :json

  resource :transaction do
    desc 'Submitting Transactions'
    params do
      requires :type, type: Symbol, values: PaymentTransaction::TYPES
      requires :merchant_token, type: String
      optional :uuid, type: String
      optional :amount, type: BigDecimal
    end
    post do
    end
  end
end
