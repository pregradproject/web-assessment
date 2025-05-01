module JsonWebToken
  extend ActiveSupport::Concern

  SECRET_KEY = Rails.application.credentials.secret_key_base

  def encode(payload, exp = 1.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
    HashWithIndifferentAccess.new(decoded[0])
  rescue
    nil
  end
end
