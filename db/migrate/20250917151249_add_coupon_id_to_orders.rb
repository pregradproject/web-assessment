class AddCouponIdToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :coupon, null: true, foreign_key: true, type: :uuid
  end
end
