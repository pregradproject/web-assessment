module Vark
  class CreateOrderServices < ApplicationService
    def initialize(test, amount = nil)
      @test = test
      @amount = amount
    end

    def call
      # Delegate to the generic Orders service
      Orders::CreateOrderServices.call(@test, @amount)
    end
  end
end
