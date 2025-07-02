module Vark
  class PaymentTokenValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :order

    def initialize(order)
      @order = order
    end

    validate :validate_order_exists
    validate :validate_order_not_paid
    validate :validate_order_not_expired

    private

    def validate_order_exists
      unless @order.present?
        errors.add(:order, 'not found')
      end
    end

    def validate_order_not_paid
      return unless @order.present?

      if @order.paid?
        errors.add(:order, 'already paid')
      end
    end

    def validate_order_not_expired
      return unless @order.present?

      if @order.expired?
        errors.add(:order, 'expired')
      end
    end
  end
end
