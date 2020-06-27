FactoryBot.define do
  factory :merchant do
    name { "MyString" }
    description { "MyText" }
    email { "MyString" }
    status { "" }
    total_transaction_sum { "9.99" }
  end
end
