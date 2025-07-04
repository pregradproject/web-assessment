module Vark
  class InitiatePaymentServices < ApplicationService
    def initialize(order)
      @order = order
    end

    def call
      return existing_payment if existing_snap_token?

      process_new_payment
    end

    private

    def existing_snap_token?
      existing_payment&.snap_token.present?
    end

    def existing_payment
      @existing_payment ||= @order.payments.pending.first
    end

    def process_new_payment
      midtrans_service = Midtrans::MidtransService.new
      result = midtrans_service.create_snap_token(@order)
      format_payment_result(result)
    end

    def format_payment_result(result)
      if result[:success]
        Payment.find(result[:payment_id])
      else
        raise CkvExceptions::UnprocessableEntityError, result[:error]
      end
    end
  end
end
