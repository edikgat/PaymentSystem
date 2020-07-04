# frozen_string_literal: true

class TransactionCreationPresenter < Grape::Entity
  expose :transaction,
         if: ->(service) { service.form.persisted? },
         using: PaymentTransactionPresenter do |service|
    service.form.payment_transaction
  end
  expose :error, if: ->(service) { service.error.present? }
end
