# frozen_string_literal: true

class PaymentTransaction < ApplicationRecord
  TYPES = %i[AuthorizeTransaction ChargeTransaction RefundTransaction ReversalTransaction].freeze
  STATUSES = %i[approved reversed refunded error].freeze

  belongs_to :merchant, inverse_of: :payment_transactions, counter_cache: true

  validates :status, inclusion: { in: STATUSES }
  validates :type, inclusion: { in: TYPES }
  validates :uuid, presence: true

  scope :approved, -> { where(status: :approved) }

  class << self
    def find_sti_class(type_name)
      ActiveSupport::Dependencies.constantize(type_name)
    end
  end
end
