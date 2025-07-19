module Vark
  class PaymentTokenValidator
    def initialize(order)
      @validator = Orders::PaymentTokenValidator.new(order)
    end

    def valid?
      @validator.valid?
    end

    def errors
      @validator.errors
    end
  end
end
