module Orders
  class CreateOrderSerializer < ApplicationSerializer
    attributes(
      :id,
      :order_number,
      :amount,
      :status,
      :expires_at,
      :created_at,
      :description,
      :original_amount,
      :coupon_discount_amount,
      :certificate_status
    )

    attribute :test_type do |object|
      object.test_type
    end

    attribute :testable do |object|
      if object.testable.present?
        {
          id: object.testable.id,
          type: object.testable_type,
          status: object.testable.status
        }
      else
        {
          id: nil,
          type: object.testable_type,
          status: nil
        }
      end
    end

    attribute :payment do |object|
      payment = object.payments.last
      if payment
        {
          id: payment.id,
          status: payment.status,
          midtrans_order_id: payment.midtrans_order_id,
          paid_at: payment.paid_at,
          payment_method: payment.payment_method
        }
      end
    end

    attribute :can_download_certificate do |object|
      object.can_download_certificate?
    end

    attribute :coupon do |object|
      if object.has_coupon?
        {
          code: object.coupon.code,
          discount_type: object.coupon.discount_type,
          display_discount: object.coupon.display_discount
        }
      end
    end

    attribute :pricing do |object|
      {
        final_amount: object.final_amount,
        has_discount: object.has_coupon?,
        discount_percentage: object.discount_percentage
      }
    end
  end
end
