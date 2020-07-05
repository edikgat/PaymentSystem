# frozen_string_literal: true

class Merchant
  class PaymentTransactionsController < BaseController
    def index
      @payment_transactions = scope.decorate
    end

    def show
      @payment_transaction = scope.find(params[:id]).decorate
    end

    private

    def scope
      current_merchant.payment_transactions
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
end
