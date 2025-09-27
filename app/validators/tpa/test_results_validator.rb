module Tpa
  class TestResultsValidator
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :tpa_test

    validates :tpa_test, presence: true
    validate :test_must_be_completed
    validate :test_must_have_answers

    def initialize(tpa_test)
      @tpa_test = tpa_test
      super(tpa_test: @tpa_test)
    end

    private

    def test_must_be_completed
      return unless tpa_test

      unless tpa_test.completed?
        errors.add(:tpa_test, 'Test must be completed to view results')
      end
    end

    def test_must_have_answers
      return unless tpa_test

      if tpa_test.tpa_answers.empty?
        errors.add(:tpa_test, 'Test must have submitted answers to generate results')
      end
    end
  end
end
