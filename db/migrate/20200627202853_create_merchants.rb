class CreateMerchants < ActiveRecord::Migration[5.2]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.text :description
      t.string :email, null: false
      t.enum :status, limit: [:active, :inactive], default: :active, null: false
      t.decimal :total_transaction_sum, null: false, default: 0.0
      t.string :token, null: false
      t.timestamps
    end

    add_index :merchants, :email, unique: true
    add_index :merchants, :token, unique: true
  end
end
