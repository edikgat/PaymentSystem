# frozen_string_literal: true

require('factory_bot_rails')

Admin.create!(email: 'admin@test.com', password: 12_345_678, password_confirmation: 12_345_678)
FactoryBot.create_list(:merchant, 5).each do |merchant|
  FactoryBot.create_list(:payment_transaction, 3, merchant: merchant).each do |auth_tr|
    FactoryBot.create_list(
      :charge_transaction,
      3,
      authorize_transaction: auth_tr,
      amount: 5,
      merchant: auth_tr.merchant,
      customer_email: auth_tr.customer_email,
      customer_phone: auth_tr.customer_phone
    )
  end
end
