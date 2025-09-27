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

        result = Orders::CreateOrderServices.call(@test, nil, params[:coupon_code])
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

        validate = Orders::CertificateGenerationValidator.new(order)
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
        @test = find_test_by_type || raise_test_not_found
      end

      def find_test_by_type
        return current_user.vark_tests.find(params[:vark_test_id]) if params[:vark_test_id].present?
        return current_user.ai_knowledge_tests.find(params[:ai_knowledge_test_id]) if params[:ai_knowledge_test_id].present?
        return current_user.behavioral_learning_tests.find(params[:behavioral_learning_test_id]) if params[:behavioral_learning_test_id].present?
        return current_user.comprehensive_assessment_tests.find(params[:comprehensive_assessment_test_id]) if params[:comprehensive_assessment_test_id].present?
        current_user.tpa_tests.find(params[:tpa_test_id]) if params[:tpa_test_id].present?
      end

      def raise_test_not_found
        raise CkvExceptions::NotFoundError, 'Test not found'
      end
    end
  end
end
