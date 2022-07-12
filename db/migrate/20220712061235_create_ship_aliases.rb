class CreateShipAliases < ActiveRecord::Migration[7.0]
  def change
    create_table :ship_aliases do |t|
      t.string :qq, null: false
      t.string :name, null: false
      t.string :ship_id, null: false
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :ship_aliases, %i[name ship_id], unique: true
  end
end
