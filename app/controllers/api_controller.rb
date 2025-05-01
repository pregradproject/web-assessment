class ApiController < ActionController::API
  include JsonWebToken
  include ActionController::RequestForgeryProtection
  include Response
  include ExceptionHandler

  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  respond_to :json

  rescue_from ActionController::RoutingError, with: -> { no_routes }

  def no_routes
    json_response({
                    routing_error: I18n.t('error.no_routes',
                                          method: request.method,
                                          path: request.path)
                  }, :not_found, true)
  end

  def current_user
    @current_user ||= process_current_user
  end

  private
  def authenticate_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = decode(token)
    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def process_current_user
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = decode(token)
    User.find_by(id: decoded[:user_id]) if decoded
  end
end
