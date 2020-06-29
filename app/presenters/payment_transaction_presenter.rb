class PaymentTransactionPresenter < Grape::Entity
  expose :uuid
  expose :type
  expose :status
  expose :amount, if: ->(transaction, _) { transaction.amount.present? }
end
