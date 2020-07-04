# frozen_string_literal: true

class ReversalTransaction < PaymentTransaction
  belongs_to :authorize_transaction,
             inverse_of: :reversal_transactions,
             foreign_key: :parent_payment_transaction_id

  validates :status, inclusion: { in: %i[approved error].freeze }

  state_machine :status, initial: :approved do
    event :error do
      transition(approved: :error)
    end
  end
end
