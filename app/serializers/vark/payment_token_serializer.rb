module Vark
  class PaymentTokenSerializer < ApplicationSerializer
    def initialize(object)
      @object = object
    end

    def to_h
      Orders::PaymentTokenSerializer.new(@object).to_h
    end
  end
end
