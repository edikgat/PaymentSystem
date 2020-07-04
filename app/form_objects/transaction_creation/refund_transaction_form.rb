# frozen_string_literal: true

module TransactionCreation
  class RefundTransactionForm < BaseForm
    validates :charge_transaction_status,
              inclusion: { in: [:approved], message: :status_should_be_approved },
              if: :charge_transaction

    delegate :status, to: :charge_transaction, prefix: true

    validates :amount, presence: true
    validate :equal_to_charge_transaction_amount

    delegate :amount, to: :payment_transaction

    def process_success
      merchant.total_transaction_sum -= payment_transaction.amount
      merchant.save!
      charge_transaction.refund!
    end

    private

    def build_payment_transaction
      @payment_transaction = RefundTransaction.new
      @payment_transaction.merchant = merchant
      @payment_transaction.charge_transaction = charge_transaction
      @payment_transaction.assign_attributes(sanitized_params)
      @payment_transaction.customer_email = charge_transaction.customer_email
      @payment_transaction.customer_phone = charge_transaction.customer_phone
      @payment_transaction.uuid = generate_uuid
    end

    def supported_params
      [:amount]
    end

    def charge_transaction
      @charge_transaction ||= merchant.charge_transactions
                                      .find_by!(uuid: params[:uuid])
    end

    def equal_to_charge_transaction_amount
      charge_transaction.amount != payment_transaction.amount &&
        errors.add(:amount, :amount_should_be_equal_to_charge_transaction_amount, count: charge_transaction.amount)
    end
  end
end
