
module Vark
  class CreateServices < ApplicationService
    def initialize(vark_question_set, current_user)
      @vark_question_set = vark_question_set
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        create_vark_test
      end

      @vark_test
    end

    private

    def create_vark_test
      @vark_test = @current_user.vark_tests.create!(
        vark_question_set: @vark_question_set,
        started_at: Time.current,
        status: :in_progress
      )
    end
  end
end
