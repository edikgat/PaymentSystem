FactoryBot.define do
  factory :merchant do
    sequence(:name) { |n| "#{n}_#{Faker::Company.name}" }
    description { Faker::Lorem.paragraph }
    sequence(:email) { |n| "#{n}_admin_#{Faker::Internet.email}" }
    status { :active }
    total_transaction_sum { 0.0 }
    sequence(:token) { |n| "token_#{n}" }
  end
end
