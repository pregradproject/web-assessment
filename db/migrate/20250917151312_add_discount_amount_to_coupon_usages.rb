class AddDiscountAmountToCouponUsages < ActiveRecord::Migration[8.0]
  def change
    add_column :coupon_usages, :discount_amount, :decimal, precision: 10, scale: 2, null: false, default: 0
  end
end
