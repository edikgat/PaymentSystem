# frozen_string_literal: true

class AuthorizeTransaction < PaymentTransaction
  validates :amount, presence: true
  validates :amount,
            numericality: { greater_than: 0 },
            allow_blank: true
end
