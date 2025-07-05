class Users::PasswordChangeService < ApplicationService
  def initialize(user, current_password, new_password)
    @user = user
    @current_password = current_password
    @new_password = new_password
  end

  def call
    return false unless @user.authenticate(@current_password)

    @user.update!(password: @new_password)
    @user
  end

  private

  attr_reader :user, :current_password, :new_password
end
