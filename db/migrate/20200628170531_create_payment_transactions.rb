# frozen_string_literal: true

class CreatePaymentTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_transactions do |t|
      t.string(:uuid, limit: 36, null: false)
      t.bigint(:merchant_id, null: false)
      t.bigint(:payment_transaction_id)
      t.enum(:status, limit: %i[approved reversed refunded error], null: false, default: :approved)
      t.enum(
        :type,
        limit: %i[
          AuthorizeTransaction
          ChargeTransaction
          RefundTransaction
          ReversalTransaction
        ],
        null: false
      )
      t.decimal(:amount)
      t.string(:customer_email)
      t.string(:customer_phone)

      t.timestamps
    end
    add_index(:payment_transactions, :uuid, unique: true)
    add_foreign_key(:payment_transactions, :merchants)
    add_foreign_key(:payment_transactions, :payment_transactions)
  end
end
