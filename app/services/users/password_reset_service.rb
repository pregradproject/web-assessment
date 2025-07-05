class Users::PasswordResetService < ApplicationService
  def initialize(email)
    @email = email
  end

  def call
    user = User.find_by(email: @email)
    return false unless user

    user.generate_reset_password_token!
    UserMailer.password_reset(user).deliver_now
    true
  end

  private

  attr_reader :email
end
