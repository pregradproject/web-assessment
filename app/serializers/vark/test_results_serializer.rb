module Vark
  class TestResultsSerializer < ApplicationSerializer
    attributes(
      :visual_score,
      :aural_score,
      :read_score,
      :kinesthetic_score,
      :min_score,
      :max_score
    )

    attribute :total_score do |object|
      object.total_score
    end

    attribute :scores_breakdown do |object|
      [
        {
          category: 'Visual',
          code: 'V',
          score: object.visual_score,
          percentage: object.percentage_for_category('V')
        },
        {
          category: 'Aural',
          code: 'A',
          score: object.aural_score,
          percentage: object.percentage_for_category('A')
        },
        {
          category: 'Read/Write',
          code: 'R',
          score: object.read_score,
          percentage: object.percentage_for_category('R')
        },
        {
          category: 'Kinesthetic',
          code: 'K',
          score: object.kinesthetic_score,
          percentage: object.percentage_for_category('K')
        }
      ]
    end

    attribute :dominant_learning_styles do |object|
      object.dominant_learning_styles
    end

    attribute :learning_style_interpretation do |object|
      categories = VarkCategory.all.index_by(&:code)

      {
        visual: categories['V']&.result_text,
        aural: categories['A']&.result_text,
        read_write: categories['R']&.result_text,
        kinesthetic: categories['K']&.result_text
      }
    end
  end
end
