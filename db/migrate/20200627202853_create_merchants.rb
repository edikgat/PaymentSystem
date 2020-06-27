class CreateMerchants < ActiveRecord::Migration[5.2]
  def change
    create_table :merchants do |t|
      t.string :name, null: false
      t.text :description
      t.string :email, null: false
      t.enum :status, limit: [:active, :inactive], default: :active, null: false
      t.decimal :total_transaction_sum, null: false, default: 0.0

      t.timestamps
    end
  end
end
