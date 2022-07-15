class CreateAdmins < ActiveRecord::Migration[7.0]
  def change
    create_table :admins do |t|
      t.string :username, null: false
      t.string :password, null: false
      t.datetime :updated_at_min, null: false, default: Time.zone.now

      t.timestamps
    end
  end
end
