module Api
  module V1
    class UsersController < ApiController
      before_action :authenticate_user!, only: :show

      def register
        user = User.new(user_params)
        if user.save
          token = encode(user_id: user.id)
          render json: { token: token, user: user }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def show
        render json: @current_user
      end

      def profile
        render json: current_user
      end

      def login
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          token = encode(user_id: user.id)
          render json: { token: token }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
