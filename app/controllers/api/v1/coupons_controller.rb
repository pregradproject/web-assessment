module Api
  module V1
    class CouponsController < ApiController
      before_action :authenticate_user!

      def validate
        validate = Coupons::ValidateCouponValidator.new(params[:coupon_code], current_user, params[:amount].to_f)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        result = Coupons::ValidateCouponServices.call(params[:coupon_code], current_user, params[:amount].to_f)

        if result[:valid]
          json_response(Coupons::CouponValidationSerializer.new(result).to_h, :ok, false)
        else
          raise CkvExceptions::UnprocessableEntityError, { coupon_code: [ result[:message] ] }
        end
      end

      private

      def coupon_params
        params.require(:coupon).permit(:coupon_code, :amount)
      end
    end
  end
end
