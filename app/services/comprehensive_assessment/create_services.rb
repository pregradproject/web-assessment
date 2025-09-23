module ComprehensiveAssessment
  class CreateServices < ApplicationService
    def initialize(comprehensive_assessment_question_set, current_user)
      @comprehensive_assessment_question_set = comprehensive_assessment_question_set
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        create_comprehensive_assessment_test
      end

      @comprehensive_assessment_test
    end

    private

    def create_comprehensive_assessment_test
      @comprehensive_assessment_test = @current_user.comprehensive_assessment_tests.create!(
        comprehensive_assessment_question_set: @comprehensive_assessment_question_set,
        started_at: Time.current,
        status: :in_progress
      )
    end
  end
end
