module Vark
  class CreateOrderValidator
    include ActiveModel::Validations

    attr_reader :test, :amount

    def initialize(test, amount = nil)
      @test = test
      @amount = amount
    end

    validates :test, presence: true
    validate :test_must_be_completed
    validate :order_must_not_exist
    validate :amount_must_be_positive, if: -> { amount.present? }

    def valid?
      super
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    private

    def test_must_be_completed
      return unless test.present?

      errors.add(:test, 'must be completed first') unless test.completed?
    end

    def order_must_not_exist
      return unless test.present?

      errors.add(:test, 'already has an order') if test.order.present?
    end

    def amount_must_be_positive
      return unless amount.present?

      errors.add(:amount, 'must be greater than 0') unless amount.to_f > 0
    end
  end
end
