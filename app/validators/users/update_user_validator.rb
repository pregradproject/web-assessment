module Users
  class UpdateUserValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name, :email, :phone, :avatar, :birthday

    def initialize(params)
      @name = params[:name]
      @email = params[:email]
      @phone = params[:phone]
      @avatar = params[:avatar]
      @birthday = params[:birthday]
    end

    validates :name, presence: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :phone, presence: true, format: { with: /\A\+?[0-9\s\-()]+\z/, message: 'must be a valid phone number' }
    validates :avatar, file_size: { less_than: 5.megabytes }, if: -> { avatar.present? }
    validates :birthday, presence: true, date: { before: Proc.new { Date.today }, message: 'must be a valid date in the past' }
  end
end
