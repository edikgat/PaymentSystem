# frozen_string_literal: true

class PaymentTransactionsRemovingJob < ApplicationJob
  queue_as :payment_transactions

  rescue_from(Exception) do |exception|
    Rails.logger.info("_ERROR_#{exception.class}_#{exception.message}")
  end

  def perform
    puts('start removing old records')
    scope.find_each do |auth_tr|
      process_remove(auth_tr)
    end
  end

  private

  def process_remove(auth_tr)
    in_transaction do
      auth_tr.destroy
      Merchant.reset_counters(auth_tr.merchant_id, :payment_transactions)
    end
  end

  def scope
    AuthorizeTransaction.for_remove
  end

  def in_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::StaleObjectError
    false
  end
end
