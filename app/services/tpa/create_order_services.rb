module Tpa
  class CreateOrderServices < ApplicationService
    def initialize(user, coupon_code = nil)
      @user = user
      @coupon_code = coupon_code
    end

    def call
      validate_user
      create_order
      apply_coupon if @coupon_code.present?
      @order
    end

    private

    attr_reader :user, :coupon_code, :order

    def validate_user
      raise CkvExceptions::NotFoundError, 'User not found' unless user.present?
    end

    def create_order
      ActiveRecord::Base.transaction do
        @order = Order.create!(
          user: user,
          amount: Configs::ConfigServices.tpa_price,
          original_amount: Configs::ConfigServices.tpa_price,
          category: :tpa_certificate,
          description: "TPA Assessment Certificate for #{user.name}",
          status: :pending
        )
      end
    end

    def apply_coupon
      coupon_validation = Coupons::ValidateCouponServices.call(@coupon_code, user, order.amount)

      raise CkvExceptions::UnprocessableEntityError, { coupon_code: [ coupon_validation[:message] ] } unless coupon_validation[:valid]

      Coupons::ApplyCouponServices.call(order, coupon_validation[:coupon], coupon_validation[:discount_amount])
    end
  end
end
