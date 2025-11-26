module Tpa
  class AutoCreateTestServices < ApplicationService
    def initialize(order)
      @order = order
    end

    def call
      return nil unless should_create_test?

      ActiveRecord::Base.transaction do
        create_test
        link_test_to_order
      end

      @tpa_test
    end

    private

    def should_create_test?
      @order.present? &&
        @order.tpa_certificate? &&
        @order.paid? &&
        @order.testable.nil?
    end

    def create_test
      question_set = TpaQuestionSet.find_by(active: true)
      return nil unless question_set

      @tpa_test = @order.user.tpa_tests.create!(
        tpa_question_set: question_set,
        status: :in_progress,
        started_at: Time.current
      )
    end

    def link_test_to_order
      @order.update!(testable: @tpa_test)
    end
  end
end
