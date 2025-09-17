module Coupons
  class ApplyCouponServices < ApplicationService
    def initialize(order, coupon, discount_amount)
      @order = order
      @coupon = coupon
      @discount_amount = discount_amount
    end

    def call
      ActiveRecord::Base.transaction do
        update_order_with_coupon
        create_coupon_usage
      end

      @order
    end

    private

    def update_order_with_coupon
      @order.update!(
        coupon: @coupon,
        original_amount: @order.amount,
        coupon_discount_amount: @discount_amount,
        amount: [ @order.amount - @discount_amount, 0 ].max
      )
    end

    def create_coupon_usage
      CouponUsage.create!(
        coupon: @coupon,
        user: @order.user,
        order: @order,
        discount_amount: @discount_amount,
        used_at: Time.current
      )
    end
  end
end
