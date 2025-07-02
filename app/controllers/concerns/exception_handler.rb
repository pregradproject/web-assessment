module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |exception|
      raise exception
    end

    rescue_from Exceptions::UnprocessableRequest do |exception|
      render_unprocessable_entity({}, exception)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      err = I18n.t('activerecord.errors.messages.record_not_found',
                   model: e.model)
      json_response({
                      errors: err,
                      status: :not_found
                    }, :not_found, true)
    end

    rescue_from ActiveRecord::RecordNotUnique do |_e|
      err = I18n.t('activerecord.errors.messages.already_exist')
      json_response({
                      errors: err,
                      status: :unprocessable_entity
                    }, :unprocessable_entity, true)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      data = { message: e.message, params: e.record.errors }
      response = { code: '422', message: e.message, data: data, error: true,
                   status: :unprocessable_entity, errors: e.record.errors }
      render json: response, status: :unprocessable_entity
    end

    rescue_from ActiveRecord::Deadlocked,
                ActiveRecord::ConnectionTimeoutError,
                ActiveRecord::QueryCanceled do |exception|
      message = I18n.t('activerecord.errors.messages.general')

      payload = error_payload(exception, message)

      serve_error(payload, :internal_server_error)
    end

    rescue_from Exceptions::UnauthorizedAccess do |e|
      message = I18n.t('error.forbidden')

      payload = error_payload(e, message)

      serve_error(payload, :forbidden)
    end

    rescue_from ActiveModel::ValidationError do |e|
      response = { message: I18n.t('error.validation_error') }

      response[:params] = e.model.errors if e.respond_to?(:model)

      json_response(response, :unprocessable_entity, true)
    end

    rescue_from CkvExceptions::ForbiddenError do |e|
      response = { code: e.code, message: e.message, error: true, status: :forbidden }
      render json: response, status: :forbidden
    end

    rescue_from CkvExceptions::UnprocessableEntityError do |e|
      response = { code: e.code, error: true,
                   status: :unprocessable_entity, errors: e.errors }
      render json: response, status: :unprocessable_entity
    end
  end

  def error_payload(exception, message)
    payload = {
      message: message
    }

    payload[:message] = I18n.t('error.internal_error') if Rails.env.production?

    build_payload_additional_data(exception, payload)
  end

  def build_payload_additional_data(exception, payload)
    return payload if Rails.env.production?

    payload[:backtrace] = exception.backtrace
    payload[:trigger] = exception.class.to_s
    payload
  end

  def serve_error(payload, status)
    json_response(payload, status, true)
  end
end
