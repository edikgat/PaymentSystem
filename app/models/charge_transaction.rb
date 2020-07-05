# frozen_string_literal: true

class ChargeTransaction < PaymentTransaction
  belongs_to :authorize_transaction,
             inverse_of: :charge_transactions,
             foreign_key: :parent_payment_transaction_id
  has_many :refund_transactions,
           inverse_of: :charge_transaction,
           foreign_key: :parent_payment_transaction_id,
           dependent: :destroy

  validates :status, inclusion: { in: %i[approved refunded error].freeze }

  state_machine :status, initial: :approved do
    event :error do
      transition(approved: :error)
    end

    event :refund do
      transition(approved: :refunded)
    end
  end
end
