class AddConsumedAndPublicToPantryItems < ActiveRecord::Migration
  def change
    add_column(:pantry_items, :consumed, :boolean)
    add_column(:pantry_items, :consumed_at, :string)
    add_column(:pantry_items, :public, :boolean, :default => true)
  end
end
