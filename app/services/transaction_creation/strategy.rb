# frozen_string_literal: true

module TransactionCreation
  class Strategy
    attr_reader :params, :error, :merchant, :type

    def initialize(type:, params:, merchant:)
      @params = params
      @merchant = merchant
      @type = type
    end

    def form
      @form ||= form_class.new(params, merchant)
    end

    def create
      in_transaction do
        if form.valid?
          form.process_success
        else
          form.set_error
          @error = form.error
        end
        form.save
      end
    end

    private

    def form_class
      "TransactionCreation::#{type}Form".constantize
    end

    def in_transaction
      ActiveRecord::Base.transaction do
        yield
      end
      error.blank?
    rescue ActiveRecord::RecordInvalid, StateMachine::InvalidTransition => e
      @error = e.message
      false
    end
  end
end
