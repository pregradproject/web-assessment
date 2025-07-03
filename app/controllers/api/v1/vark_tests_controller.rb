module Api
  module V1
    class VarkTestsController < ApiController
      before_action :authenticate_user!
      before_action :set_vark_question_set!, only: %w[create]
      before_action :set_vark_test, only: %w[show submit_answers results]
      before_action :validate_test_submission, only: %w[submit_answers]

      def create
        vark_test = Vark::CreateServices.call(@vark_question_set, current_user)

        json_response(Vark::TestSerializer.new(vark_test).to_h, :ok, false)
      end

      def active_question_set
        question_set = VarkQuestionSet.active

        json_response(Vark::ActiveQuestionSetSerializer.new(question_set).to_h, :ok, false)
      end

      def show
        json_response(Vark::TestSerializer.new(@vark_test).to_h, :ok, false)
      end

      def submit_answers
        validate = Vark::SubmitAnswerValidator.new(params, @vark_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        Vark::SubmitAnswersServices.call(@vark_test, params, current_user)

        json_response('ok', :ok, false)
      end

      def results
        validate = Vark::TestResultsValidator.new(@vark_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        json_response(Vark::TestResultsSerializer.new(@vark_test.vark_result_level).to_h, :ok, false)
      end

      private

      def set_vark_test
        @vark_test = current_user.vark_tests.find(params[:id])
      end

      def set_vark_question_set!
        @vark_question_set = VarkQuestionSet.find(params[:vark_question_set_id])
      end

      def validate_test_submission
        raise CkvExceptions::ForbiddenError, 'Vark test is already completed' if @vark_test.completed?
        raise CkvExceptions::ForbiddenError, 'Vark test time is expired' if test_expired?
      end

      def test_expired?
        return false unless @vark_test.started_at && @vark_test.vark_question_set.time_limit.positive?

        Time.current > @vark_test.started_at + @vark_test.vark_question_set.time_limit.seconds
      end
    end
  end
end
