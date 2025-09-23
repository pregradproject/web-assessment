module Api
  module V1
    class ComprehensiveAssessmentTestsController < ApiController
      before_action :authenticate_user!
      before_action :set_comprehensive_assessment_question_set!, only: %w[create]
      before_action :set_comprehensive_assessment_test, only: %w[show submit_answers results]
      before_action :validate_test_submission, only: %w[submit_answers]

      def index
        comprehensive_assessment_tests = current_user.comprehensive_assessment_tests.includes(:comprehensive_assessment_question_set, :comprehensive_assessment_result_level, :order)
                                                    .order(created_at: :desc)

        json_response(ComprehensiveAssessment::TestListSerializer.new(comprehensive_assessment_tests).to_h, :ok, false)
      end

      def create
        comprehensive_assessment_test = ComprehensiveAssessment::CreateServices.call(@comprehensive_assessment_question_set, current_user)

        json_response(ComprehensiveAssessment::TestSerializer.new(comprehensive_assessment_test).to_h, :ok, false)
      end

      def active_question_set
        question_set = ComprehensiveAssessmentQuestionSet.current_active

        json_response(ComprehensiveAssessment::ActiveQuestionSetSerializer.new(question_set).to_h, :ok, false)
      end

      def show
        json_response(ComprehensiveAssessment::TestSerializer.new(@comprehensive_assessment_test).to_h, :ok, false)
      end

      def submit_answers
        validate = ComprehensiveAssessment::SubmitAnswerValidator.new(params, @comprehensive_assessment_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        ComprehensiveAssessment::SubmitAnswersServices.call(@comprehensive_assessment_test, params, current_user)

        json_response('ok', :ok, false)
      end

      def results
        validate = ComprehensiveAssessment::TestResultsValidator.new(@comprehensive_assessment_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        json_response(ComprehensiveAssessment::TestResultsSerializer.new(@comprehensive_assessment_test.comprehensive_assessment_result_level).to_h, :ok, false)
      end

      private

      def set_comprehensive_assessment_test
        @comprehensive_assessment_test = current_user.comprehensive_assessment_tests.find(params[:id])
      end

      def set_comprehensive_assessment_question_set!
        @comprehensive_assessment_question_set = ComprehensiveAssessmentQuestionSet.find(params[:comprehensive_assessment_question_set_id])
      end

      def validate_test_submission
        raise CkvExceptions::ForbiddenError, 'Comprehensive Assessment test is already completed' if @comprehensive_assessment_test.completed?
        raise CkvExceptions::ForbiddenError, 'Comprehensive Assessment test time is expired' if test_expired?
      end

      def test_expired?
        return false unless @comprehensive_assessment_test.started_at && @comprehensive_assessment_test.comprehensive_assessment_question_set.time_limit.positive?

        Time.current > @comprehensive_assessment_test.started_at + @comprehensive_assessment_test.comprehensive_assessment_question_set.time_limit.seconds
      end
    end
  end
end
