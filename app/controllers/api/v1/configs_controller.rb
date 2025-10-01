module Api
  module V1
    class ConfigsController < ApiController
      before_action :authenticate_user!

      def show
        config_groups = Configs::ConfigServices.frontend_config_groups

        json_response(config_groups, :ok, false)
      end
    end
  end
end
