module BehavioralLearning
  class TestResultsValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :behavioral_learning_test

    def initialize(behavioral_learning_test)
      @behavioral_learning_test = behavioral_learning_test
    end

    validate :validate_test_status
    validate :validate_results_exist

    private

    def validate_test_status
      unless @behavioral_learning_test.completed?
        errors.add(:behavioral_learning_test, 'Test must be completed to view results')
      end
    end

    def validate_results_exist
      unless @behavioral_learning_test.behavioral_learning_result_level.present?
        errors.add(:behavioral_learning_test, 'Results are not available for this test')
      end
    end
  end
end
