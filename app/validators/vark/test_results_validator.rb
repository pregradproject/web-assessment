module Vark
  class TestResultsValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :vark_test

    def initialize(vark_test)
      @vark_test = vark_test
    end

    validate :validate_test_status
    validate :validate_results_exist

    private

    def validate_test_status
      unless @vark_test.completed?
        errors.add(:vark_test, 'Test must be completed to view results')
      end
    end

    def validate_results_exist
      unless @vark_test.vark_result_level.present?
        errors.add(:vark_test, 'Results are not available for this test')
      end
    end
  end
end
