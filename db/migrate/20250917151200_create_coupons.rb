class CreateCoupons < ActiveRecord::Migration[8.0]
  def change
    create_table :coupons, id: :uuid do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.integer :discount_type, null: false
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.datetime :expiry_date
      t.integer :max_uses_per_user, default: 1, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :coupons, :code, unique: true
    add_index :coupons, :active
    add_index :coupons, :expiry_date
    add_index :coupons, [:active, :expiry_date]
  end
end
