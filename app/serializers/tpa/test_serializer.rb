module Tpa
  class TestSerializer
    include JSONAPI::Serializer

    def initialize(tpa_test, options = {})
      @tpa_test = tpa_test
      @include_questions = options[:include_questions] || false
    end

    def to_h
      {
        id: @tpa_test.id,
        status: @tpa_test.status,
        started_at: @tpa_test.started_at,
        completed_at: @tpa_test.completed_at,
        time_remaining: @tpa_test.time_remaining,
        question_set: question_set_data,
        questions: questions_data,
        created_at: @tpa_test.created_at
      }.compact
    end

    private

    def question_set_data
      {
        id: @tpa_test.tpa_question_set.id,
        name: @tpa_test.tpa_question_set.name,
        version: @tpa_test.tpa_question_set.version,
        time_limit: @tpa_test.tpa_question_set.time_limit
      }
    end

    def questions_data
      return [] unless @include_questions

      @tpa_test.questions.includes(:tpa_category).map do |question|
        {
          id: question.id,
          question_text: question.question_text,
          option_a: question.option_a,
          option_b: question.option_b,
          option_c: question.option_c,
          option_d: question.option_d,
          option_e: question.option_e,
          category: question.tpa_category.name,
          difficulty_level: question.difficulty_level
        }
      end
    end
  end
end
