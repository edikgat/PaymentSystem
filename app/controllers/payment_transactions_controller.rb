# frozen_string_literal: true

class PaymentTransactionsController < ApplicationController
  def index
    @payment_transactions = PaymentTransaction.all.decorate
  end

  def show
    @payment_transaction = PaymentTransaction.find(params[:id]).decorate
  end

  private

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
