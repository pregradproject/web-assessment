module Api
  module V1
    class OrdersController < ApiController
      before_action :authenticate_user!, except: [ :webhook ]
      before_action :set_test, only: [ :show, :create, :payment_token, :generate_certificate, :download_certificate ]

      def show
        order = @test.order
        raise CkvExceptions::NotFoundError, 'Order not found' unless order

        json_response(Orders::CreateOrderSerializer.new(order).to_h, :ok, false)
      end

      def create
        validate = Orders::CreateOrderValidator.new(@test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        result = Orders::CreateOrderServices.call(@test)
        json_response(Orders::CreateOrderSerializer.new(result).to_h, :created, false)
      end

      def payment_token
        order = @test.order
        validate = Orders::PaymentTokenValidator.new(order)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        result = Orders::InitiatePaymentServices.call(order)

        json_response(Orders::PaymentTokenSerializer.new(result).to_h, :ok, false)
      end

      def webhook
        result = Orders::ProcessPaymentNotificationServices.call(params.to_unsafe_h)

        if result[:success]
          json_response({ message: result[:message] }, :ok, false)
        else
          raise CkvExceptions::UnprocessableEntityError, result[:error]
        end
      end

      def generate_certificate
        order = @test.order
        raise CkvExceptions::NotFoundError, 'Order not found' unless order

        validate = Orders::CertificateDownloadValidator.new(order)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        result = Certificates::GenerateCertificateService.call(order)

        if result[:success]
          json_response({ message: result[:message] }, :ok, false)
        else
          raise CkvExceptions::UnprocessableEntityError, result[:error]
        end
      end

      def download_certificate
        order = @test.order

        validate = Orders::CertificateDownloadValidator.new(order)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        send_data order.certificate_pdf.download,
                  filename: "certificate_#{order.order_number}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end

      private

      def set_test
        if params[:vark_test_id].present?
          @test = current_user.vark_tests.find(params[:vark_test_id])
        elsif params[:ai_knowledge_test_id].present?
          @test = current_user.ai_knowledge_tests.find(params[:ai_knowledge_test_id])
        else
          raise CkvExceptions::NotFoundError, 'Test not found'
        end
      end
    end
  end
end
