class GoogleAuthService < ApplicationService
  def initialize(id_token)
    @id_token = id_token
  end

  def call
    validate_token
  end

  private

  attr_reader :id_token

  def validate_token
    require 'google/auth/id_tokens'
    payload = Google::Auth::IDTokens.verify_oidc(id_token)

    {
      success: true,
      google_id: payload['sub'],
      email: payload['email'],
      name: payload['name'],
      picture: payload['picture'],
      email_verified: payload['email_verified']
    }
  rescue Google::Auth::IDTokens::VerificationError => e
    {
      success: false,
      error: "Invalid Google token: #{e.message}"
    }
  rescue StandardError => e
    {
      success: false,
      error: "Token validation failed: #{e.message}"
    }
  end
end
