module Coupons
  class CouponValidationSerializer
    include JSONAPI::Serializer

    def initialize(data)
      @data = data
    end

    def to_h
      if @data[:valid]
        {
          valid: true,
          message: @data[:message],
          coupon: {
            code: @data[:coupon].code,
            discount_type: @data[:coupon].discount_type,
            display_discount: @data[:coupon].display_discount
          },
          pricing: {
            original_amount: @data[:original_amount],
            discount_amount: @data[:discount_amount],
            final_amount: @data[:final_amount]
          }
        }
      else
        {
          valid: false,
          message: @data[:message]
        }
      end
    end
  end
end
