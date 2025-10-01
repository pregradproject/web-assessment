module Tpa
  class ResultCalculationServices < ApplicationService
    def initialize(tpa_test)
      @tpa_test = tpa_test
    end

    def call
      return @tpa_test.tpa_result_level if @tpa_test.tpa_result_level.present?

      ActiveRecord::Base.transaction do
        complete_test
        create_result_level
        generate_certificate
      end

      @tpa_test.tpa_result_level
    end

    private

    attr_reader :tpa_test

    def complete_test
      @tpa_test.complete_test! if @tpa_test.in_progress?
    end

    def create_result_level
      @tpa_test.create_tpa_result_level!(
        total_questions: @tpa_test.questions.count,
        total_score: calculate_total_score,
        verbal_score: calculate_category_score('V'),
        quantitative_score: calculate_category_score('Q'),
        analytic_score: calculate_category_score('A'),
        spatial_score: calculate_category_score('S')
      )
    end

    def calculate_total_score
      @tpa_test.tpa_answers.correct_answers.count
    end

    def calculate_category_score(category_code)
      @tpa_test.tpa_answers
               .joins(tpa_question: :tpa_category)
               .where(tpa_categories: { code: category_code })
               .correct_answers
               .count
    end

    def generate_certificate
      GenerateCertificateJob.perform_later(@tpa_test.order.id)
    end
  end
end
