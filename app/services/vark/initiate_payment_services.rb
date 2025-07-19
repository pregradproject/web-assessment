module Vark
  class InitiatePaymentServices < ApplicationService
    def initialize(order)
      @order = order
    end

    def call
      # Delegate to the generic Orders service
      Orders::InitiatePaymentServices.call(@order)
    end
  end
end
