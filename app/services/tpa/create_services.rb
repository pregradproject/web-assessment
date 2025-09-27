module Tpa
  class CreateServices < ApplicationService
    def initialize(user, tpa_question_set_id)
      @user = user
      @tpa_question_set_id = tpa_question_set_id
    end

    def call
      @tpa_question_set = TpaQuestionSet.find(@tpa_question_set_id)

      @tpa_test = @user.tpa_tests.create!(
        tpa_question_set: @tpa_question_set,
        status: :in_progress,
        started_at: Time.current
      )

      @tpa_test
    end

    private

    attr_reader :user, :tpa_question_set_id, :tpa_question_set, :tpa_test
  end
end
