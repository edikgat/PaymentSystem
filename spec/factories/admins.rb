FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "#{n}_admin_#{Faker::Internet.email}" }
    password { '12345678' }
    password_confirmation { '12345678' }
  end
end
