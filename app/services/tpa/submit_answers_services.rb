module Tpa
  class SubmitAnswersServices < ApplicationService
    def initialize(tpa_test, answers_data)
      @tpa_test = tpa_test
      @answers_data = answers_data
    end

    def call
      ActiveRecord::Base.transaction do
        process_answers
        mark_test_as_completed
        generate_certificate
        @tpa_test.reload
      end

      'ok'
    end

    private

    attr_reader :tpa_test, :answers_data

    def process_answers
      answers_data.each do |answer_data|
        tpa_question = TpaQuestion.find(answer_data[:tpa_question_id])

        @tpa_test.tpa_answers.create_or_find_by(
          tpa_question: tpa_question
        ) do |answer|
          answer.selected_option = answer_data[:selected_option]
          answer.answered_at = Time.current
        end
      end
    end

    def mark_test_as_completed
      @tpa_test.complete_test!
    end

    def generate_certificate
      GenerateCertificateJob.perform_later(@tpa_test.order.id)
    end
  end
end
