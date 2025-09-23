module ComprehensiveAssessment
  class TestResultsValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :comprehensive_assessment_test

    def initialize(comprehensive_assessment_test)
      @comprehensive_assessment_test = comprehensive_assessment_test
    end

    validate :test_must_be_completed
    validate :result_level_must_exist

    private

    def test_must_be_completed
      unless @comprehensive_assessment_test&.completed?
        errors.add(:test, 'must be completed to view results')
      end
    end

    def result_level_must_exist
      return unless @comprehensive_assessment_test&.completed?

      unless @comprehensive_assessment_test.comprehensive_assessment_result_level.present?
        errors.add(:results, 'not available - test results have not been calculated')
      end
    end
  end
end
