module Tpa
  class ActiveQuestionSetSerializer
    include JSONAPI::Serializer

    def initialize(tpa_question_set)
      @tpa_question_set = tpa_question_set
    end

    def to_h
      {
        id: @tpa_question_set.id,
        name: @tpa_question_set.name,
        version: @tpa_question_set.version,
        time_limit: @tpa_question_set.time_limit,
        total_questions: @tpa_question_set.total_questions,
        questions_by_category: @tpa_question_set.questions_by_category,
        active: @tpa_question_set.active,
        created_at: @tpa_question_set.created_at,
        updated_at: @tpa_question_set.updated_at
      }
    end
  end
end
