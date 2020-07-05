# frozen_string_literal: true

class MerchantDecorator < ApplicationDecorator
  delegate_all

  def total_profit
    "$#{object.total_transaction_sum}"
  end
end
