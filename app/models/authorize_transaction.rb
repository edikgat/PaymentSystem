# frozen_string_literal: true

class AuthorizeTransaction < PaymentTransaction
  has_many :charge_transactions,
           inverse_of: :authorize_transaction,
           foreign_key: :parent_payment_transaction_id

  has_many :reversal_transactions,
           inverse_of: :authorize_transaction,
           foreign_key: :parent_payment_transaction_id

  validates :status, inclusion: { in: %i[approved reversed error].freeze }

  state_machine :status, initial: :approved do
    event :error do
      transition(approved: :error)
    end

    event :reverse do
      transition(approved: :reversed)
    end
  end
end
