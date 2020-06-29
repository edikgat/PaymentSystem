class Merchant < ApplicationRecord
  STATUSES = %i(active inactive).freeze
  validates :status, inclusion: { in: STATUSES }
end
