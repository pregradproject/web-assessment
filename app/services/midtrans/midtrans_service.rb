require 'net/http'
require 'json'
require 'base64'

module Midtrans
  class MidtransService
  SANDBOX_BASE_URL = 'https://app.sandbox.midtrans.com/snap/v1'
  PRODUCTION_BASE_URL = 'https://app.midtrans.com/snap/v1'

  def initialize
    @server_key = Rails.application.credentials.dig(:midtrans, :server_key) || ENV['MIDTRANS_SERVER_KEY']
    @merchant_id = Rails.application.credentials.dig(:midtrans, :merchant_id) || ENV['MIDTRANS_MERCHANT_ID']
    @is_production = ENV['MIDTRANS_ENVIRONMENT'] == 'production'
    @base_url = @is_production ? PRODUCTION_BASE_URL : SANDBOX_BASE_URL

    Rails.logger.info "Midtrans Config: Environment=#{ENV['MIDTRANS_ENVIRONMENT']}, Production=#{@is_production}, URL=#{@base_url}"
  end

  def create_snap_token(order)
    payment = create_payment_record(order)
    return payment_creation_failed unless payment

    process_snap_token_creation(order, payment)
  rescue StandardError => e
    handle_snap_token_error(e, payment)
  end

  def handle_notification(notification_data)
    payment = find_payment_by_order_id(notification_data['order_id'])
    return payment_not_found_error unless payment

    update_payment_status(payment, notification_data)
    { success: true, message: 'Notification processed' }
  rescue StandardError => e
    handle_notification_error(e)
  end

  private

  def payment_creation_failed
    { success: false, error: 'Failed to create payment record' }
  end

  def process_snap_token_creation(order, payment)
    payload = build_snap_payload(order, payment)
    response = make_snap_request(payload)

    if response[:success]
      update_payment_with_token(payment, response)
      snap_token_success_response(response, payment)
    else
      handle_snap_token_failure(payment, response)
    end
  end

  def handle_snap_token_error(error, payment)
    Rails.logger.error "Midtrans API Error: #{error.message}"
    payment&.destroy
    { success: false, error: 'Payment processing failed' }
  end

  def update_payment_with_token(payment, response)
    payment.update!(
      snap_token: response[:data]['token'],
      midtrans_response: response[:data].to_json
    )
  end

  def snap_token_success_response(response, payment)
    {
      success: true,
      snap_token: response[:data]['token'],
      payment_id: payment.id
    }
  end

  def handle_snap_token_failure(payment, response)
    payment.destroy
    { success: false, error: response[:error] }
  end

  def find_payment_by_order_id(order_id)
    Payment.find_by(midtrans_order_id: order_id)
  end

  def payment_not_found_error
    { success: false, error: 'Payment not found' }
  end

  def update_payment_status(payment, notification_data)
    transaction_status = notification_data['transaction_status']
    fraud_status = notification_data['fraud_status']

    case transaction_status
    when 'capture', 'settlement'
      handle_successful_payment(payment, notification_data) if fraud_accepted?(fraud_status)
    when 'pending'
      payment.update!(status: :pending)
    when 'deny', 'cancel', 'expire'
      handle_failed_payment(payment, transaction_status)
    end
  end

  def fraud_accepted?(fraud_status)
    fraud_status == 'accept' || fraud_status.nil?
  end

  def handle_successful_payment(payment, notification_data)
    payment.update!(
      status: :settlement,
      paid_at: Time.current,
      midtrans_transaction_id: notification_data['transaction_id'],
      midtrans_response: notification_data.to_json
    )
    payment.order.update!(status: :paid)

    # Trigger certificate generation if test is completed
    if payment.order.testable&.completed?
      GenerateCertificateJob.perform_later(payment.order.id)
    end
  end

  def handle_failed_payment(payment, transaction_status)
    payment.update!(status: transaction_status.to_sym)
    payment.order.update!(status: :cancelled) if transaction_status == 'cancel'
    payment.order.update!(status: :expired) if transaction_status == 'expire'
  end

  def handle_notification_error(error)
    Rails.logger.error "Midtrans Notification Error: #{error.message}"
    { success: false, error: 'Notification processing failed' }
  end

  def execute_http_request(payload)
    uri = URI("#{@base_url}/transactions")
    http = setup_http_client(uri)
    request = build_http_request(uri, payload)
    http.request(request)
  end

  def setup_http_client(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http
  end

  def build_http_request(uri, payload)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Basic #{Base64.strict_encode64("#{@server_key}:")}"
    request.body = payload.to_json
    request
  end

  def handle_api_response(response)
    parsed_response = JSON.parse(response.body)

    if response.code == '201'
      { success: true, data: parsed_response }
    else
      handle_api_error(response, parsed_response)
    end
  end

  def handle_api_error(response, parsed_response)
    Rails.logger.error "Midtrans API Error: #{response.code} - #{parsed_response}"
    { success: false, error: parsed_response['error_messages']&.join(', ') || 'Unknown error' }
  end

  def handle_json_parse_error(error)
    Rails.logger.error "JSON Parse Error: #{error.message}"
    { success: false, error: 'Invalid response from payment gateway' }
  end

  def handle_http_error(error)
    Rails.logger.error "HTTP Request Error: #{error.message}"
    { success: false, error: 'Network error occurred' }
  end

  def create_payment_record(order)
    order.payments.create!(
      amount: order.amount,
      payment_method: 'midtrans',
      status: :pending
    )
  rescue StandardError => e
    Rails.logger.error "Payment Record Creation Error: #{e.message}"
    nil
  end

  def build_snap_payload(order, payment)
    {
      transaction_details: {
        order_id: payment.midtrans_order_id,
        gross_amount: order.amount.to_i
      },
      customer_details: {
        first_name: order.user.name.split(' ').first,
        last_name: order.user.name.split(' ')[1..].join(' '),
        email: order.user.email
      },
      item_details: [
        {
          id: 'certificate',
          price: order.amount.to_i,
          quantity: 1,
          name: 'VARK Learning Style Certificate'
        }
      ],
      callbacks: {
        finish: Rails.application.routes.url_helpers.api_v1_payments_webhook_url(host: callback_host)
      },
      expiry: {
        start_time: Time.current.strftime('%Y-%m-%d %H:%M:%S %z'),
        unit: 'hours',
        duration: 24
      },
      custom_field1: order.id,
      custom_field2: order.user.id
    }
  end

  def make_snap_request(payload)
    response = execute_http_request(payload)
    handle_api_response(response)
  rescue JSON::ParserError => e
    handle_json_parse_error(e)
  rescue StandardError => e
    handle_http_error(e)
  end

  def callback_host
    Rails.env.production? ? ENV['PRODUCTION_HOST'] || 'your-production-domain.com' : 'localhost:3000'
  end
  end
end
