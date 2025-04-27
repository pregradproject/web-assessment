module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :authenticate, options
    end
  end

  def encode(payload, type: :access)
    now = Time.now.to_i
    exp = case type
    when :access then now + 3.minutes.to_i
    when :refresh then now + 7.days.to_i
    end

    JWT.encode(
      {
        data: {
          id: payload.id,
          email_address: payload.email_address
        },
        exp: exp,
        iat: now,
        iss: "rails_jwt_api",
        aud: "rails_jwt_client",
        sub: type.to_s,
        jti: SecureRandom.uuid,
        nbf: now + 1.second.to_i
      },
      Rails.application.credentials.jwt_secret,
      "HS256"
    )
  end

  def decode(token)
    JWT.decode(token, Rails.application.credentials.jwt_secret, true, { algorithm: "HS256" })
  end

  def get_token
    auth_header = request.headers["Authorization"]
    return nil if auth_header.blank?

    auth_header.split(" ").last
  end

  def current_user
    token = get_token
    return nil if token.blank?

    decoded = decode(token)
    decoded.first["data"].with_indifferent_access
  end

  def authenticate
    #   token = get_token
    #   return render json: { error: "Access token required" }, status: :unauthorized if token.blank?
    #
    #   decode(token)
    # rescue JWT::DecodeError
    #   render json: { error: "Invalid token" }, status: :unauthorized
    # rescue JWT::ExpiredSignature
    #   render json: { error: "Token has expired" }, status: :unauthorized
  end
end
