class UserMailer < ApplicationMailer
  def password_reset(user)
    @user = user
    @reset_url = "#{ENV.fetch('FRONTEND_URL', 'https://cakravia.com')}/reset-password?token=#{@user.reset_password_token}"

    mail(
      to: @user.email,
      subject: 'Reset Your Password - Cakravia'
    )
  end
end
