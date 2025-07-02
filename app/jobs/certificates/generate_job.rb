module Certificates
  class GenerateJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :exponentially_longer, attempts: 3

    def perform(order_id)
      order = Order.find(order_id)

      # Double check the order is in the right state
      return unless order.paid? && order.testable.completed?
      return if order.certificate_ready?

      Rails.logger.info "Generating certificate for order #{order.order_number}"

      result = Certificates::GenerateService.call(order)

      if result[:success]
        Rails.logger.info "Certificate generated successfully for order #{order.order_number}"
        # Optionally notify user or trigger email
        # CertificateMailer.certificate_ready(order).deliver_now
      else
        Rails.logger.error "Certificate generation failed for order #{order.order_number}: #{result[:error]}"
        # Optionally notify admins of the failure
      end
    end
  end
end
