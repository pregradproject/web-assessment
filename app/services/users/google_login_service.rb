module Users
  class GoogleLoginService < ApplicationService
    def initialize(google_data)
      @google_data = google_data
    end

    def call
      handle_google_authentication
    end

    private

    attr_reader :google_data

    def handle_google_authentication
      existing_user = find_existing_user

      if existing_user
        link_google_account(existing_user) if existing_user.auth_provider == 'email'
        existing_user
      else
        create_google_user
      end
    end

    def find_existing_user
      User.find_by(email: google_data[:email]) ||
      User.find_by(google_id: google_data[:google_id])
    end

    def link_google_account(user)
      user.update!(
        google_id: google_data[:google_id],
        google_email: google_data[:email],
        auth_provider: 'both'
      )
    end

    def create_google_user
      User.create!(
        name: google_data[:name],
        email: google_data[:email],
        google_id: google_data[:google_id],
        google_email: google_data[:email],
        auth_provider: 'google',
        password: SecureRandom.hex(16)
      )
    end
  end
end
