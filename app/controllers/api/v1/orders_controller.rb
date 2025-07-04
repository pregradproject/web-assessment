module Api
  module V1
    class OrdersController < ApiController
      before_action :authenticate_user!, except: [ :webhook ]
      before_action :set_vark_test, only: [ :show, :create, :payment_token, :download_certificate ]

      def show
        order = @vark_test.order
        raise CkvExceptions::NotFoundError, 'Order not found' unless order

        json_response(Vark::CreateOrderSerializer.new(order).to_h, :ok, false)
      end

      def create
        validate = Vark::CreateOrderValidator.new(@vark_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        result = Vark::CreateOrderServices.call(@vark_test)
        json_response(Vark::CreateOrderSerializer.new(result).to_h, :created, false)
      end

      def payment_token
        order = @vark_test.order
        validate = Vark::PaymentTokenValidator.new(order)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        result = Vark::InitiatePaymentServices.call(order)

        json_response(Vark::PaymentTokenSerializer.new(result).to_h, :ok, false)
      end

      def webhook
        result = Vark::ProcessPaymentNotificationServices.call(params.to_unsafe_h)

        if result[:success]
          json_response({ message: result[:message] }, :ok, false)
        else
          raise CkvExceptions::UnprocessableEntityError, result[:error]
        end
      end

      def download_certificate
        order = @vark_test.order

        validate = Vark::CertificateDownloadValidator.new(order)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        send_data order.certificate_pdf.download,
                  filename: "certificate_#{order.order_number}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end

      private

      def set_vark_test
        @vark_test = current_user.vark_tests.find(params[:vark_test_id])
      end
    end
  end
end
