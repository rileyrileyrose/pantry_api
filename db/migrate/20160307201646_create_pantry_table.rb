class CreatePantryTable < ActiveRecord::Migration
  def change
    create_table :pantry_items_users do |t|
      t.integer :user_id
      t.integer :pantry_item_id
      t.integer :quantity
      t.string :exp_date
    end
  end
end
