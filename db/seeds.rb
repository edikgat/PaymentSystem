require 'factory_bot_rails'

Admin.create!(email: 'admin@test.com', password: 12345678, password_confirmation: 12345678)
FactoryBot.create_list(:merchant, 5).each do |merchant|
  FactoryBot.create_list(:payment_transaction, 3, merchant: merchant)
end
