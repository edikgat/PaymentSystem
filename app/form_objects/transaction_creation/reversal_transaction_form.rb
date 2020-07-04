# frozen_string_literal: true

module TransactionCreation
  class ReversalTransactionForm < BaseForm
    private

    def build_payment_transaction
      @payment_transaction = ReversalTransaction.new
      @payment_transaction.merchant = merchant
      @payment_transaction.authorize_transaction = authorize_transaction
      @payment_transaction.assign_attributes(sanitized_params)
      @payment_transaction.customer_email = authorize_transaction.customer_email
      @payment_transaction.customer_phone = authorize_transaction.customer_phone
      @payment_transaction.uuid = generate_uuid
    end

    def supported_params
      []
    end

    def authorize_transaction
      @authorize_transaction ||= merchant.payment_transactions
                                         .approved.where(type: :AuthorizeTransaction)
                                         .find_by!(uuid: params[:uuid])
    end
  end
end
