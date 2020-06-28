class AddTokenToMerchants < ActiveRecord::Migration[5.2]
  def change
    add_column :merchants, :token, :string, null: false
  end
end
