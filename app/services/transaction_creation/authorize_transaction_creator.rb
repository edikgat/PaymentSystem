# frozen_string_literal: true

module TransactionCreation
  class AuthorizeTransactionCreator < Base
    attr_reader :params, :error

    def initialize(params)
      @params = params
    end

    def create
      in_transaction do
        if form.valid?
        else
          form.set_error
          @error = form.error
        end
        form.save
      end
    end

    def form
      @form ||= form_class.new(params)
    end

    private

    def form_class
      AuthorizeTransactionForm
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
