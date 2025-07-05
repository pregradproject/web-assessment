module Users
  class PasswordChangeValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :current_password, :new_password, :new_password_confirmation, :user

    def initialize(params, user = nil)
      @current_password = params[:current_password]
      @new_password = params[:new_password]
      @new_password_confirmation = params[:new_password_confirmation]
      @user = user
    end

    validates :current_password, presence: true
    validates :new_password, presence: true, length: { minimum: 6 }
    validates :new_password_confirmation, presence: true

    validate :passwords_match
    validate :current_password_valid

    private

    def passwords_match
      return if new_password.blank? || new_password_confirmation.blank?

      errors.add(:new_password_confirmation, 'does not match new password') if new_password != new_password_confirmation
    end

    def current_password_valid
      return if current_password.blank? || user.blank?

      errors.add(:current_password, 'is incorrect') unless user.authenticate(current_password)
    end
  end
end
