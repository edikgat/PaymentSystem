# frozen_string_literal: true

module TransactionCreation
  class BaseForm
    include ActiveModel::Validations

    attr_reader :payment_transaction

    def error
      errors.full_messages.join(', ')
    end

    def set_error
      payment_transaction.error!
    end

    private

    def generate_uuid
      10.times do
        new_uuid = SecureRandom.uuid
        return new_uuid unless PaymentTransaction.where(uuid: new_uuid).exists?
      end
      nil
    end
  end
end
