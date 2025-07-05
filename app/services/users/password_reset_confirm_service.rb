class Users::PasswordResetConfirmService < ApplicationService
  def initialize(token, new_password)
    @token = token
    @new_password = new_password
  end

  def call
    user = User.with_reset_token(@token).first
    return false unless user&.reset_password_token_valid?

    user.reset_password!(@new_password)

    if user.auth_provider == 'google'
      user.update!(auth_provider: 'both')
    end

    user
  end

  private

  attr_reader :token, :new_password
end
