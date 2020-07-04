# frozen_string_literal: true

class CreateMerchants < ActiveRecord::Migration[5.2]
  def change
    create_table :merchants do |t|
      t.string(:name, null: false)
      t.text(:description)
      t.string(:email, null: false)
      t.enum(:status, limit: %i[active inactive], default: :active, null: false)
      t.decimal(:total_transaction_sum, null: false, default: 0.0)
      t.string(:encrypted_password, null: false, default: '')
      t.bigint(:lock_version, null: false)
      t.timestamps
    end

    add_index(:merchants, :email, unique: true)
  end
end
