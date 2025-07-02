module Api
  module V1
    class OrdersController < ApiController
      before_action :authenticate_user!, except: [ :webhook ]
      before_action :set_vark_test, only: [ :show, :create, :payment_token, :generate_certificate, :download_certificate ]

      def show
        order = @vark_test.order
        raise CkvExceptions::NotFoundError, 'Order not found' unless order

        json_response(OrderServices::OrderSerializer.new(order).to_h, :ok, false)
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

      def generate_certificate
        order = @vark_test.order
        raise CkvExceptions::NotFoundError, 'Order not found' unless order
        raise CkvExceptions::UnprocessableEntityError, 'Order not paid' unless order.paid?
        raise CkvExceptions::UnprocessableEntityError, 'Test not completed' unless @vark_test.completed?

        if order.certificate_ready?
          json_response({ message: 'Certificate already generated', status: 'ready' }, :ok, false)
        elsif order.certificate_generating?
          json_response({ message: 'Certificate generation in progress', status: 'generating' }, :ok, false)
        else
          # Queue the certificate generation job
          Certificates::GenerateJob.perform_later(order.id)
          json_response({ message: 'Certificate generation started', status: 'queued' }, :accepted, false)
        end
      end

      def download_certificate
        order = @vark_test.order
        raise CkvExceptions::NotFoundError, 'Order not found' unless order
        raise CkvExceptions::UnprocessableEntityError, 'Certificate not ready' unless order.certificate_ready?

        # Send the PDF file
        send_data order.certificate_pdf.download,
                  filename: "VARK_Certificate_#{order.order_number}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end

      def webhook
        result = OrderServices::ProcessPaymentNotificationServices.call(params.to_unsafe_h)

        if result[:success]
          json_response(OrderServices::WebhookResponseSerializer.new(result).to_h, :ok, false)
        else
          raise CkvExceptions::UnprocessableEntityError, result[:error]
        end
      end

      private

      def set_vark_test
        @vark_test = current_user.vark_tests.find(params[:vark_test_id])
      end
    end
  end
end
