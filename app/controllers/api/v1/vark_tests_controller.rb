module Api
  module V1
    class VarkTestsController < ApiController
      before_action :authenticate_user!
      before_action :set_vark_question_set!, only: %w[create]
      # before_action :set_vark_test, only: %w[show submit_answers]
      # before_action :validate_test_submission, only: %w[submit_answers]

      def create
        vark_test = Vark::CreateServices.call(@vark_question_set, current_user)

        json_response(Vark::TestSerializer.new(vark_test).to_h, :ok, false)
      end

      def active_question_set
        question_set = VarkQuestionSet.active

        json_response(Vark::ActiveQuestionSetSerializer.new(question_set).to_h, :ok, false)
      end

      private

      def set_vark_test
        @vark_test = current_user.vark_tests.find(params[:id])
      end

      def set_vark_question_set!
        @vark_question_set = VarkQuestionSet.find(params[:vark_question_set_id])
      end
    end
  end
end
