# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      sign_out(:merchant)
      admin_payment_transactions_path
    elsif resource.is_a?(Merchant)
      sign_out(:admin)
      merchant_payment_transactions_path
    end
  end
end
