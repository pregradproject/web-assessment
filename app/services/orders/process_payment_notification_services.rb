module Orders
  class ProcessPaymentNotificationServices < ApplicationService
    def initialize(notification_data)
      @notification_data = notification_data
    end

    def call
      midtrans_service = Midtrans::MidtransService.new
      midtrans_service.handle_notification(@notification_data)
    end
  end
end
