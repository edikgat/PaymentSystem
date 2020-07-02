# frozen_string_literal: true

class PaymentTransactionsController < ApplicationController
  before_action :set_payment_transaction, only: [:show]

  def index
    @payment_transactions = PaymentTransaction.all
  end

  def show; end

  private

  def set_payment_transaction
    @payment_transaction = PaymentTransaction.find(params[:id])
  end

  def payment_transaction_params
    params.require(:payment_transaction).permit(
      :uuid,
      :merchant_id,
      :payment_transaction_id,
      :status,
      :type,
      :amount,
      :customer_email,
      :customer_phone
    )
  end
end
