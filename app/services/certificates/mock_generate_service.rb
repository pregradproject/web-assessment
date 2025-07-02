module Certificates
  class MockGenerateService < ApplicationService
    def initialize(order)
      @order = order
      @vark_test = order.testable
      @user = order.user
    end

    def call
      return failure_result('Order not paid') unless @order.paid?
      return failure_result('Test not completed') unless @vark_test.completed?
      return failure_result('Certificate already generated') if @order.certificate_ready?

      @order.update!(certificate_status: :generating)

      begin
        # Create a mock PDF for development
        mock_pdf_content = create_mock_pdf
        attach_certificate(mock_pdf_content)
        success_result
      rescue => e
        handle_generation_error(e)
      end
    end

    private

    def create_mock_pdf
      # Create a simple text-based PDF content for testing
      "Mock PDF Certificate for #{@user.name}\nOrder: #{@order.order_number}\nGenerated: #{Time.current}"
    end

    def attach_certificate(pdf_content)
      filename = "certificate_#{@order.order_number}_#{Time.current.strftime('%Y%m%d')}.txt"
      
      @order.certificate_pdf.attach(
        io: StringIO.new(pdf_content),
        filename: filename,
        content_type: 'text/plain'
      )
      
      @order.update!(
        certificate_status: :generated,
        certificate_generated_at: Time.current
      )
    end

    def handle_generation_error(error)
      Rails.logger.error "Mock certificate generation failed for order #{@order.id}: #{error.message}"
      
      @order.update!(
        certificate_status: :generation_failed,
        certificate_generation_error: error.message
      )
      
      failure_result(error.message)
    end

    def success_result
      { success: true, order: @order }
    end

    def failure_result(message)
      { success: false, error: message }
    end
  end
end