module Certificates
  class GenerateCertificateService < ApplicationService
    def initialize(order)
      @order = order
    end

    def call
      validate_order!
      html = generate_html
      pdf_data = generate_pdf_from_html(html)
      attach_certificate(pdf_data)
      { success: true, message: 'Certificate generated successfully' }
    rescue StandardError => e
      { success: false, error: "Certificate generation failed: #{e.message}" }
    end

    private

    attr_reader :order

    def validate_order!
      raise 'Order not found' unless order&.present?
      raise 'Test not completed' unless order.testable&.completed?
      raise 'Order not paid' unless order.paid?
    end

    def generate_html
      result = CertificateTemplateService.new(order).call
      raise result[:error] unless result[:success]
      result[:html]
    end

    def generate_pdf_from_html(html)
      Tempfile.create([ 'cert', '.html' ]) do |html_file|
        html_file.write(html)
        html_file.close
        generate_pdf(html_file.path)
      end
    end

    def generate_pdf(html_file_path)
      browser = Ferrum::Browser.new(
        headless: true,
        window_size: [ 1200, 800 ],
        process_timeout: 60,
        timeout: 60,
        browser_options: {
          'no-sandbox': nil,
          'disable-dev-shm-usage': nil,
          'disable-gpu': nil,
          'disable-software-rasterizer': nil,
          'disable-background-timer-throttling': nil,
          'disable-backgrounding-occluded-windows': nil,
          'disable-renderer-backgrounding': nil,
          'disable-features': 'TranslateUI',
          'disable-ipc-flooding-protection': nil
        }
      )
      browser.go_to("file://#{html_file_path}")
      sleep 2
      pdf_base64 = browser.pdf(
        paper_width: 8.27, paper_height: 11.7,
        margin_top: 0, margin_bottom: 0,
        margin_left: 0, margin_right: 0,
        print_background: true, scale: 1.0
      )
      Base64.decode64(pdf_base64)
    ensure
      browser&.quit
    end

    def attach_certificate(pdf_data)
      Tempfile.create([ 'cert', '.pdf' ], binmode: true) do |pdf_file|
        pdf_file.write(pdf_data)
        pdf_file.rewind
        order.certificate_pdf.attach(
          io: pdf_file,
          filename: "certificate_#{order.order_number}.pdf",
          content_type: 'application/pdf'
        )
      end
    end
  end
end
