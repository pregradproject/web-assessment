module Api
  module V1
    class BehavioralLearningTestsController < ApiController
      before_action :authenticate_user!
      before_action :set_behavioral_learning_question_set!, only: %w[create]
      before_action :set_behavioral_learning_test, only: %w[show submit_answers results]
      before_action :validate_test_submission, only: %w[submit_answers]

      def index
        behavioral_learning_tests = current_user.behavioral_learning_tests.includes(:behavioral_learning_question_set, :behavioral_learning_result_level, :order)
                                               .order(created_at: :desc)

        json_response(BehavioralLearning::TestListSerializer.new(behavioral_learning_tests).to_h, :ok, false)
      end

      def create
        behavioral_learning_test = BehavioralLearning::CreateServices.call(@behavioral_learning_question_set, current_user)

        json_response(BehavioralLearning::TestSerializer.new(behavioral_learning_test).to_h, :ok, false)
      end

      def active_question_set
        question_set = BehavioralLearningQuestionSet.current_active

        json_response(BehavioralLearning::ActiveQuestionSetSerializer.new(question_set).to_h, :ok, false)
      end

      def show
        json_response(BehavioralLearning::TestSerializer.new(@behavioral_learning_test).to_h, :ok, false)
      end

      def submit_answers
        validate = BehavioralLearning::SubmitAnswerValidator.new(params, @behavioral_learning_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        BehavioralLearning::SubmitAnswersServices.call(@behavioral_learning_test, params, current_user)

        json_response('ok', :ok, false)
      end

      def results
        validate = BehavioralLearning::TestResultsValidator.new(@behavioral_learning_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        json_response(BehavioralLearning::TestResultsSerializer.new(@behavioral_learning_test.behavioral_learning_result_level).to_h, :ok, false)
      end

      private

      def set_behavioral_learning_test
        @behavioral_learning_test = current_user.behavioral_learning_tests.find(params[:id])
      end

      def set_behavioral_learning_question_set!
        @behavioral_learning_question_set = BehavioralLearningQuestionSet.find(params[:behavioral_learning_question_set_id])
      end

      def validate_test_submission
        raise CkvExceptions::ForbiddenError, 'Behavioral Learning test is already completed' if @behavioral_learning_test.completed?
        raise CkvExceptions::ForbiddenError, 'Behavioral Learning test time is expired' if test_expired?
      end

      def test_expired?
        return false unless @behavioral_learning_test.started_at && @behavioral_learning_test.behavioral_learning_question_set.time_limit.positive?

        Time.current > @behavioral_learning_test.started_at + @behavioral_learning_test.behavioral_learning_question_set.time_limit.seconds
      end
    end
  end
end
