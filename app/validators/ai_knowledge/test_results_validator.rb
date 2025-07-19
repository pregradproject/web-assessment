module AiKnowledge
  class TestResultsValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :ai_knowledge_test

    def initialize(ai_knowledge_test)
      @ai_knowledge_test = ai_knowledge_test
    end

    validate :validate_test_status
    validate :validate_results_exist

    private

    def validate_test_status
      unless @ai_knowledge_test.completed?
        errors.add(:ai_knowledge_test, 'Test must be completed to view results')
      end
    end

    def validate_results_exist
      unless @ai_knowledge_test.ai_knowledge_result_level.present?
        errors.add(:ai_knowledge_test, 'Results are not available for this test')
      end
    end
  end
end
