module Api
  module V1
    class AiKnowledgeTestsController < ApiController
      before_action :authenticate_user!
      before_action :set_ai_knowledge_question_set!, only: %w[create]
      before_action :set_ai_knowledge_test, only: %w[show submit_answers results]
      before_action :validate_test_submission, only: %w[submit_answers]

      def index
        ai_knowledge_tests = current_user.ai_knowledge_tests.includes(:ai_knowledge_question_set, :ai_knowledge_result_level, :order)
                                                            .order(created_at: :desc)

        json_response(AiKnowledge::TestListSerializer.new(ai_knowledge_tests).to_h, :ok, false)
      end

      def create
        ai_knowledge_test = AiKnowledge::CreateServices.call(@ai_knowledge_question_set, current_user)

        json_response(AiKnowledge::TestSerializer.new(ai_knowledge_test).to_h, :ok, false)
      end

      def active_question_set
        question_set = AiKnowledgeQuestionSet.active

        json_response(AiKnowledge::ActiveQuestionSetSerializer.new(question_set).to_h, :ok, false)
      end

      def show
        json_response(AiKnowledge::TestSerializer.new(@ai_knowledge_test).to_h, :ok, false)
      end

      def submit_answers
        validate = AiKnowledge::SubmitAnswerValidator.new(params, @ai_knowledge_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        AiKnowledge::SubmitAnswersServices.call(@ai_knowledge_test, params, current_user)

        json_response('ok', :ok, false)
      end

      def results
        validate = AiKnowledge::TestResultsValidator.new(@ai_knowledge_test)
        raise CkvExceptions::UnprocessableEntityError, validate.errors unless validate.valid?

        json_response(AiKnowledge::TestResultsSerializer.new(@ai_knowledge_test.ai_knowledge_result_level).to_h, :ok, false)
      end

      private

      def set_ai_knowledge_test
        @ai_knowledge_test = current_user.ai_knowledge_tests.find(params[:id])
      end

      def set_ai_knowledge_question_set!
        @ai_knowledge_question_set = AiKnowledgeQuestionSet.find(params[:ai_knowledge_question_set_id])
      end

      def validate_test_submission
        raise CkvExceptions::ForbiddenError, 'AI Knowledge test is already completed' if @ai_knowledge_test.completed?
        raise CkvExceptions::ForbiddenError, 'AI Knowledge test time is expired' if test_expired?
      end

      def test_expired?
        return false unless @ai_knowledge_test.started_at && @ai_knowledge_test.ai_knowledge_question_set.time_limit.positive?

        Time.current > @ai_knowledge_test.started_at + @ai_knowledge_test.ai_knowledge_question_set.time_limit.seconds
      end
    end
  end
end
