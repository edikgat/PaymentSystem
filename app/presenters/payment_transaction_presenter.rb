# frozen_string_literal: true

class PaymentTransactionPresenter < Grape::Entity
  expose :uuid
  expose :type
  expose :status
  expose :amount, if: ->(transaction, _) { transaction.amount.present? }
  expose :customer_email, if: ->(transaction, _) { transaction.customer_email.present? }
  expose :customer_phone, if: ->(transaction, _) { transaction.customer_phone.present? }
  expose :merchant_email do |transaction|
    transaction.merchant.email
  end
end
