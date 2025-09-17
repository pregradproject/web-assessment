module Coupons
  class ValidateCouponValidator
    include ActiveModel::Validations

    attr_accessor :coupon_code, :user, :amount

    def initialize(coupon_code, user, amount)
      @coupon_code = coupon_code&.strip
      @user = user
      @amount = amount
    end

    validates :coupon_code, presence: { message: 'Coupon code is required' }
    validates :user, presence: { message: 'User is required' }
    validates :amount, presence: { message: 'Amount is required' }
    validates :amount, numericality: { greater_than: 0, message: 'Amount must be greater than 0' }

    validate :coupon_code_format
    validate :coupon_exists
    validate :coupon_is_active, if: :coupon_exists?
    validate :coupon_not_expired, if: :coupon_exists?
    validate :user_usage_limit_not_exceeded, if: :coupon_exists?

    def coupon
      @coupon ||= Coupon.find_by(code: @coupon_code&.upcase) if @coupon_code.present?
    end

    private

    def coupon_code_format
      return unless @coupon_code.present?

      unless @coupon_code.match?(/\A[A-Z0-9]+\z/)
        errors.add(:coupon_code, 'Coupon code must contain only letters and numbers')
      end
    end

    def coupon_exists
      return unless @coupon_code.present?

      unless coupon
        errors.add(:coupon_code, 'Invalid coupon code')
      end
    end

    def coupon_exists?
      coupon.present?
    end

    def coupon_is_active
      unless coupon.active?
        errors.add(:coupon_code, 'Coupon is not active')
      end
    end

    def coupon_not_expired
      if coupon.expired?
        errors.add(:coupon_code, 'Coupon has expired')
      end
    end

    def user_usage_limit_not_exceeded
      unless coupon.valid_for_user?(@user)
        errors.add(:coupon_code, 'Coupon usage limit exceeded for this user')
      end
    end
  end
end
