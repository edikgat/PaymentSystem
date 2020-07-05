# frozen_string_literal: true

FactoryBot.define do
  factory :payment_transaction, class: 'AuthorizeTransaction' do
    sequence(:uuid) { |n| "#{n}UUID" }
    association :merchant, factory: :merchant
    parent_payment_transaction_id { nil }
    status { :approved }
    type { 'AuthorizeTransaction' }
    amount { '9.99' }
    sequence(:customer_email) { |n| "#{n}_admin_#{Faker::Internet.email}" }
    customer_phone { Faker::PhoneNumber.cell_phone_in_e164 }
  end

  factory :authorize_transaction, class: 'AuthorizeTransaction', parent: :payment_transaction do
    type { 'AuthorizeTransaction' }
    amount { '20.00' }
  end

  factory :charge_transaction, class: 'ChargeTransaction', parent: :payment_transaction do
    type { 'ChargeTransaction' }
    association :authorize_transaction, factory: :authorize_transaction
    amount { '5.00' }
  end

  factory :refund_transaction, class: 'RefundTransaction', parent: :payment_transaction do
    type { 'RefundTransaction' }
    association :charge_transaction, factory: :charge_transaction
    amount { '5.00' }
  end

  factory :reversal_transaction, class: 'ReversalTransaction', parent: :payment_transaction do
    type { 'ReversalTransaction' }
    association :authorize_transaction, factory: :authorize_transaction
  end
end
