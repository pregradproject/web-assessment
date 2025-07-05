module Users
  class PasswordResetConfirmValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :token, :password, :password_confirmation

    def initialize(params)
      @token = params[:token]
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
    end

    validates :token, presence: true
    validates :password, presence: true, length: { minimum: 6 }
    validates :password_confirmation, presence: true

    validate :passwords_match
    validate :token_valid

    private

    def passwords_match
      return if password.blank? || password_confirmation.blank?

      errors.add(:password_confirmation, 'does not match password') if password != password_confirmation
    end

    def token_valid
      return if token.blank?

      user = User.with_reset_token(token).first
      if user.blank?
        errors.add(:token, 'is invalid')
      elsif !user.reset_password_token_valid?
        errors.add(:token, 'has expired')
      end
    end
  end
end
