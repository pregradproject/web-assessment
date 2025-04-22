module Api
  module V1
    class AuthController < ApplicationController
      allow_unauthenticated_access only: [ :create, :refresh ]
      def create
        @current_user = User.find_by(email_address: params[:email_address])

        if @current_user&.authenticate(params[:password])
          access_token = encode(@current_user, type: :access)
          refresh_token = encode(@current_user, type: :refresh)

          render json: {
            access_token: access_token,
            refresh_token: refresh_token
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # POST /api/auth/refresh
      def refresh
        token = get_token
        return render json: { error: "Refresh token required" }, status: :unauthorized if token.blank?

        payload, _ = decode(token)

        if payload["sub"] != "refresh"
          return render json: { error: "Invalid refresh token" }, status: :unauthorized
        end

        user_data = payload["data"].with_indifferent_access
        user = User.find_by(id: user_data[:id], email_address: user_data[:email_address])

        return render json: { error: "User not found" }, status: :unauthorized unless user

        new_access_token = encode(user, type: :access)
        render json: { access_token: new_access_token }, status: :ok
      rescue JWT::DecodeError, JWT::ExpiredSignature
        render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
      end
    end
  end
end
