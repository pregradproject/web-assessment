module Coupons
  class ValidateCouponServices < ApplicationService
    def initialize(coupon_code, user, amount)
      @coupon_code = coupon_code&.upcase&.strip
      @user = user
      @amount = amount
    end

    def call
      return validation_result(false, 'Coupon code is required') if @coupon_code.blank?

      coupon = find_coupon
      return validation_result(false, 'Invalid coupon code') unless coupon

      return validation_result(false, 'Coupon is not active') unless coupon.active?
      return validation_result(false, 'Coupon has expired') if coupon.expired?
      return validation_result(false, 'Coupon usage limit exceeded for this user') unless coupon.valid_for_user?(@user)

      discount_amount = coupon.calculate_discount(@amount)
      final_amount = [ @amount - discount_amount, 0 ].max

      validation_result(true, 'Coupon is valid', {
        coupon: coupon,
        discount_amount: discount_amount,
        final_amount: final_amount,
        original_amount: @amount
      })
    end

    private

    def find_coupon
      Coupon.find_by(code: @coupon_code)
    end

    def validation_result(valid, message, data = {})
      {
        valid: valid,
        message: message,
        **data
      }
    end
  end
end
