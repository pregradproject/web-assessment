module Vark
  class ProcessPaymentNotificationServices < ApplicationService
    def initialize(notification_data)
      @notification_data = notification_data
    end

    def call
      # Delegate to the generic Orders service
      Orders::ProcessPaymentNotificationServices.call(@notification_data)
    end
  end
end
