# frozen_string_literal: true
# frozen_string_literal: true

module TransactionCreation
  class AuthorizeTransactionForm < BaseForm
    validates :customer_email, email: true, allow_blank: true
    validates :customer_email, presence: true
    validates :customer_phone, length: { minimum: 5, maximum: 20 }, allow_blank: true
    validates :amount, presence: true
    validates :amount,
              numericality: { greater_than: 0 },
              allow_blank: true

    delegate :customer_email, :customer_phone, :amount, :persisted?, to: :payment_transaction

    def initialize(params)
      @payment_transaction = AuthorizeTransaction.new
      @payment_transaction.assign_attributes(params)
      @payment_transaction.uuid = generate_uuid
    end

    def save
      payment_transaction.save!
    end
  end
end
