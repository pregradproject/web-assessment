module Vark
  class CreateOrderValidator
    def initialize(test, amount = nil)
      @validator = Orders::CreateOrderValidator.new(test, amount)
    end

    def valid?
      @validator.valid?
    end

    def errors
      @validator.errors
    end
  end
end
