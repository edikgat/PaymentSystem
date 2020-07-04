# frozen_string_literal: true

class Merchant < ApplicationRecord
  STATUSES = %i[active inactive].freeze

  has_many :payment_transactions, inverse_of: :merchant

  validates :status, inclusion: { in: STATUSES }

  validates :email, presence: true
  validates :password, :password_confirmation, presence: true, on: :create
  validates :password, confirmation: true
  validates :email, uniqueness: { case_sensitive: false }, email: true, allow_blank: true
  validates :total_transaction_sum, presence: true
  validates :total_transaction_sum,
            numericality: { greater_than_or_equal_to: 0 },
            allow_blank: true

  devise :database_authenticatable

  scope :active, -> { where(status: :active) }
end
