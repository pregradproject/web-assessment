require 'cgi'

module Certificates
  class GenerateService < ApplicationService
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
        pdf_data = generate_pdf
        attach_certificate(pdf_data)
        success_result
      rescue => e
        handle_generation_error(e)
      end
    end

    private

    def generate_pdf
      template_service = Certificates::TemplateService.new(@order)
      html_content = template_service.render_certificate

      browser = Ferrum::Browser.new(FERRUM_OPTIONS)
      browser.goto("data:text/html;charset=utf-8,#{CGI.escape(html_content)}")

      # Wait for charts to load and animations to complete
      # Give extra time for the more complex donut charts to render
      sleep(8)

      # Wait for images to be fully loaded and all charts to render
      browser.evaluate('
        new Promise((resolve) => {
          if (document.readyState === "complete") {
            // Additional check for ApexCharts to finish rendering
            setTimeout(() => {
              resolve();
            }, 2000);
          } else {
            window.addEventListener("load", () => {
              setTimeout(() => {
                resolve();
              }, 2000);
            });
          }
        })
      ')

      # Generate PDF
      pdf_data = browser.pdf(
        landscape: false,
        paper_width: 8.27,  # A4 width in inches
        paper_height: 11.7, # A4 height in inches
        margin_top: 0.5,
        margin_bottom: 0.5,
        margin_left: 0.5,
        margin_right: 0.5,
        print_background: true
      )

      browser.quit
      pdf_data
    end

    def attach_certificate(pdf_data)
      filename = "certificate_#{@order.order_number}_#{Time.current.strftime('%Y%m%d')}.pdf"

      # Decode base64 PDF data
      binary_data = Base64.decode64(pdf_data)
      
      @order.certificate_pdf.attach(
        io: StringIO.new(binary_data),
        filename: filename,
        content_type: 'application/pdf'
      )

      @order.update!(
        certificate_status: :generated,
        certificate_generated_at: Time.current
      )
    end

    def handle_generation_error(error)
      Rails.logger.error "Certificate generation failed for order #{@order.id}: #{error.message}"

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
