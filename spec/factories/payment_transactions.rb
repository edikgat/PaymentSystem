FactoryBot.define do
  factory :payment_transaction do
    sequence(:uuid)  { |n| "#{n}UUID" }
    association :merchant, factory: :merchant
    payment_transaction_id { nil }
    status { :approved }
    type { "AuthorizeTransaction" }
    amount { "9.99" }
    sequence(:customer_email) { |n| "#{n}_admin_#{Faker::Internet.email}" }
    customer_phone { Faker::PhoneNumber.cell_phone_in_e164 }
  end
end
