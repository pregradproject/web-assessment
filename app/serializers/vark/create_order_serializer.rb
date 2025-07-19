module Vark
  class CreateOrderSerializer < ApplicationSerializer
    def initialize(object)
      @object = object
    end

    def to_h
      Orders::CreateOrderSerializer.new(@object).to_h
    end
  end
end
