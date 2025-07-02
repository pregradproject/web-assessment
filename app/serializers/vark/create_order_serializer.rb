module Vark
  class CreateOrderSerializer < ApplicationSerializer
    attributes(
      :id,
      :order_number,
      :amount,
      :status,
      :expires_at,
      :created_at,
      :description
    )

    attribute :test_type do |object|
      object.test_type
    end

    attribute :testable do |object|
      {
        id: object.testable.id,
        type: object.testable_type,
        status: object.testable.status
      }
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
  end
end
