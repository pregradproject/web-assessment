class CreateCouponUsages < ActiveRecord::Migration[8.0]
  def change
    create_table :coupon_usages, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :coupon, null: false, foreign_key: true, type: :uuid
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.datetime :used_at, null: false
      t.decimal :discount_amount, precision: 10, scale: 2, default: 0.0, null: false

      t.timestamps
    end

    add_index :coupon_usages, :user_id
    add_index :coupon_usages, :coupon_id
    add_index :coupon_usages, :order_id, unique: true
    add_index :coupon_usages, [:user_id, :coupon_id]
    add_index :coupon_usages, [:coupon_id, :used_at]
  end
end
