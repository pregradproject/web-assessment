module Orders
  class CertificateGenerationValidator
    include ActiveModel::Validations

    attr_accessor :order

    def initialize(order)
      @order = order
    end

    validate :order_exists
    validate :order_is_paid
    validate :test_is_completed
    validate :certificate_not_already_generated

    private

    def order_exists
      errors.add(:order, 'Order not found') unless @order
    end

    def order_is_paid
      return unless @order

      errors.add(:order, 'Order is not paid') unless @order.paid?
    end

    def test_is_completed
      return unless @order

      errors.add(:test, 'Test is not completed') unless @order.testable&.completed?
    end

    def certificate_not_already_generated
      return unless @order

      errors.add(:certificate, 'Certificate already generated') if @order.certificate_ready?
    end
  end
end
