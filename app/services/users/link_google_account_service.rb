module Users
  class LinkGoogleAccountService < ApplicationService
    def initialize(user, google_data)
      @user = user
      @google_data = google_data
    end

    def call
      validate_email_match
      link_account
    end

    private

    attr_reader :user, :google_data

    def validate_email_match
      return if user.email == google_data[:email]

      raise CkvExceptions::UnprocessableEntityError,
            'Google email does not match existing account email'
    end

    def link_account
      user.update!(
        google_id: google_data[:google_id],
        google_email: google_data[:email],
        auth_provider: 'both'
      )

      user
    end
  end
end
