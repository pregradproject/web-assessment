module Tpa
  class TestResultsSerializer
    include JSONAPI::Serializer

    def initialize(tpa_result_level)
      @tpa_result_level = tpa_result_level
    end

    def to_h
      {
        id: @tpa_result_level.tpa_test.id,
        total_score: @tpa_result_level.total_score,
        total_questions: @tpa_result_level.total_questions,
        average_score: @tpa_result_level.average_score,
        level_label: @tpa_result_level.level_label,
        level_message: @tpa_result_level.level_message,
        category_scores: @tpa_result_level.category_scores,
        category_breakdown: @tpa_result_level.category_breakdown,
        strongest_categories: @tpa_result_level.strongest_categories,
        weakest_categories: @tpa_result_level.weakest_categories,
        detailed_analysis: @tpa_result_level.detailed_analysis,
        test_info: @tpa_result_level.test_info
      }
    end
  end
end
