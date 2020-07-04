# frozen_string_literal: true

class RefundTransaction < PaymentTransaction
  belongs_to :charge_transaction,
             inverse_of: :refund_transactions,
             foreign_key: :parent_payment_transaction_id

  validates :status, inclusion: { in: %i[approved error].freeze }

  state_machine :status, initial: :approved do
    event :error do
      transition(approved: :error)
    end
  end
end
