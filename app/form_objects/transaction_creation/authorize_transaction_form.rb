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

    delegate :customer_email, :customer_phone, :amount, to: :payment_transaction

    def process_success; end

    private

    def build_payment_transaction
      @payment_transaction = AuthorizeTransaction.new
      @payment_transaction.merchant = merchant
      @payment_transaction.assign_attributes(sanitized_params)
      @payment_transaction.uuid = generate_uuid
    end

    def supported_params
      %i[customer_email customer_phone amount]
    end
  end
end
