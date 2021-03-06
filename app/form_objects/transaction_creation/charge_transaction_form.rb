# frozen_string_literal: true

module TransactionCreation
  class ChargeTransactionForm < BaseForm
    validates :amount, presence: true
    validates :amount,
              numericality: { greater_than: 0 },
              allow_blank: true
    validates :authorize_transaction_status,
              inclusion: { in: [:approved], message: :status_should_be_approved },
              if: :authorize_transaction

    validate :less_than_or_equal_to_remaining_balance

    delegate :amount, to: :payment_transaction
    delegate :status, to: :authorize_transaction, prefix: true

    def process_success
      merchant.total_transaction_sum += payment_transaction.amount
      merchant.save!
    end

    private

    def build_payment_transaction
      @payment_transaction = ChargeTransaction.new
      @payment_transaction.merchant = merchant
      @payment_transaction.authorize_transaction = authorize_transaction
      @payment_transaction.assign_attributes(sanitized_params)
      @payment_transaction.customer_email = authorize_transaction.customer_email
      @payment_transaction.customer_phone = authorize_transaction.customer_phone
      @payment_transaction.uuid = generate_uuid
    end

    def supported_params
      [:amount]
    end

    def authorize_transaction
      @authorize_transaction ||= merchant.authorize_transactions
                                         .find_by!(uuid: params[:uuid])
    end

    def less_than_or_equal_to_remaining_balance
      sum = authorize_transaction.charge_transactions.approved.sum(:amount)
      sum += payment_transaction.amount
      sum > authorize_transaction.amount &&
        errors.add(:amount, :sum_less_than_or_equal_blocked_amount, count: authorize_transaction.amount)
    end
  end
end
