# frozen_string_literal: true

module TransactionCreation
  class BaseForm
    include ActiveModel::Validations

    attr_reader :payment_transaction, :merchant, :params

    delegate :persisted?, to: :payment_transaction
    def initialize(params, merchant)
      @merchant = merchant
      @params = params
      build_payment_transaction
    end

    def error
      errors.full_messages.join(', ')
    end

    def set_error
      payment_transaction.error!
    end

    def save
      payment_transaction.save!
    end

    def process_success
      raise(NotImplementedError, 'not implemented')
    end

    private

    def build_payment_transaction
      raise(NotImplementedError, 'not implemented')
    end

    def sanitized_params
      params.slice(*supported_params)
    end

    def supported_params
      raise(NotImplementedError, 'not implemented')
    end

    def generate_uuid
      10.times do
        new_uuid = SecureRandom.uuid
        return new_uuid unless PaymentTransaction.where(uuid: new_uuid).exists?
      end
      nil
    end
  end
end
