class GenerateCertificateJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(order_id)
    @order = Order.find(order_id)
    update_status(:generating)
    result = Certificates::GenerateCertificateService.new(@order).call
    return on_success          if result[:success]
    on_failure(result[:error])
  rescue StandardError => e
    on_failure(e.message)
    raise
  end

  private

  attr_reader :order

  def update_status(state)
    order.update!(certificate_status: state)
  end

  def on_success
    update_status(:generated)
    Rails.logger.info "✅ Certificate generated for order #{order.id}"
  end

  def on_failure(error)
    update_status(:generation_failed)
    Rails.logger.error "❌ Cert failed for order #{order.id}: #{error}"
  end
end
