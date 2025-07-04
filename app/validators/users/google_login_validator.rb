module Users
  class GoogleLoginValidator
    include ActiveModel::Validations

    attr_accessor :id_token

    def initialize(params)
      @id_token = params[:id_token]
    end

    validates :id_token, presence: { message: 'Google ID token is required' }
    validates :id_token, format: {
      with: /\A[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\z/,
      message: 'Invalid Google ID token format'
    }
  end
end
