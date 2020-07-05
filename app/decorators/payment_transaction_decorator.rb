# frozen_string_literal: true

class PaymentTransactionDecorator < ApplicationDecorator
  delegate_all
  delegate :name, to: :merchant, prefix: true
  delegate :uuid, to: :parent_payment_transaction, prefix: true, allow_nil: true

  def parent_payment_transaction
    case object.type
    when :ChargeTransaction
      object.authorize_transaction
    when :RefundTransaction
      object.charge_transaction
    when :ReversalTransaction
      object.authorize_transaction
    end
  end

  def amount
    "$#{object.amount}" if object.amount.present?
  end
end
