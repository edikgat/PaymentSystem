class PaymentTransactionsController < ApplicationController
  before_action :set_payment_transaction, only: [:show]

  # GET /payment_transactions
  # GET /payment_transactions.json
  def index
    @payment_transactions = PaymentTransaction.all
  end

  # GET /payment_transactions/1
  # GET /payment_transactions/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_transaction
      @payment_transaction = PaymentTransaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_transaction_params
      params.require(:payment_transaction).permit(:uuid, :merchant_id, :payment_transaction_id, :status, :type, :amount, :customer_email, :customer_phone)
    end
end
