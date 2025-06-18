module Api
  module V1
    class UsersController < ApiController
      before_action :authenticate_user!, only: %w[show update profile]

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
        json_response(Users::UserSerializer.new(current_user).to_h, :ok, false)
      end

      def update
        validate = Users::UpdateUserValidator.new(params)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        update_user

        json_response(Users::UserSerializer.new(current_user).to_h, :ok, false)
      end

      def profile
        json_response(Users::UserSerializer.new(current_user).to_h, :ok, false)
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

      def update_user
        current_user.update!(
          name: params[:name],
          email: params[:email],
          phone: params[:phone],
          birthday: params[:birthday]
        )

        attach_avatar if params[:avatar].present?
      end

      def attach_avatar
          current_user.avatar.purge if current_user.avatar.attached?

          current_user.avatar.attach(
            io: params[:avatar].tempfile,
            filename: params[:avatar].original_filename,
            content_type: params[:avatar].content_type
          )
      end
    end
  end
end
