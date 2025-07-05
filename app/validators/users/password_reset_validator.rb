module Users
  class PasswordResetValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :email

    def initialize(params)
      @email = params[:email]
    end

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

    validate :user_exists

    private

    def user_exists
      return if email.blank?

      user = User.find_by(email: email)
      errors.add(:email, 'not found') unless user
    end
  end
end
