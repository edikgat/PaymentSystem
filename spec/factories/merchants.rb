# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    sequence(:name) { |n| "#{n}_#{Faker::Company.name}" }
    description { Faker::Lorem.paragraph }
    sequence(:email) { |n| "#{n}_merchant@mail.com" }
    status { :active }
    total_transaction_sum { 0.0 }
    password { '12345678' }
    password_confirmation { '12345678' }
  end
end
