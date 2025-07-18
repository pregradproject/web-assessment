module AiKnowledge
  class CreateServices < ApplicationService
    def initialize(ai_knowledge_question_set, current_user)
      @ai_knowledge_question_set = ai_knowledge_question_set
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        create_ai_knowledge_test
      end

      @ai_knowledge_test
    end

    private

    def create_ai_knowledge_test
      @ai_knowledge_test = @current_user.ai_knowledge_tests.create!(
        ai_knowledge_question_set: @ai_knowledge_question_set,
        started_at: Time.current,
        status: :in_progress
      )
    end
  end
end
