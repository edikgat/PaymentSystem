class PaymentTransaction < ApplicationRecord
  TYPES = %i(AuthorizeTransaction ChargeTransaction RefundTransaction ReversalTransaction).freeze
  STATUSES = %i(approved reversed refunded error).freeze

  belongs_to :merchant

  validates :status, inclusion: { in: STATUSES }
  validates :type, inclusion: { in: TYPES }

  class << self
    def find_sti_class(type_name)
      ActiveSupport::Dependencies.constantize(type_name)
    end
  end
end
