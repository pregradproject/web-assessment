class AddOriginalAmountAndCouponDiscountAmountToOrders < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:orders, :original_amount)
      add_column :orders, :original_amount, :decimal, precision: 10, scale: 2
    end

    unless column_exists?(:orders, :coupon_discount_amount)
      add_column :orders, :coupon_discount_amount, :decimal, precision: 10, scale: 2
    end
  end
end
