module BehavioralLearning
  class CreateServices < ApplicationService
    def initialize(behavioral_learning_question_set, current_user)
      @behavioral_learning_question_set = behavioral_learning_question_set
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        create_behavioral_learning_test
      end

      @behavioral_learning_test
    end

    private

    def create_behavioral_learning_test
      @behavioral_learning_test = @current_user.behavioral_learning_tests.create!(
        behavioral_learning_question_set: @behavioral_learning_question_set,
        started_at: Time.current,
        status: :in_progress
      )
    end
  end
end
