class VarkResultLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id min_score max_score visual_score aural_score read_score kinesthetic_score created_at updated_at]
  end

  belongs_to :vark_test
  belongs_to :user

  def total_score
    (visual_score || 0) + (aural_score || 0) + (read_score || 0) + (kinesthetic_score || 0)
  end

  def scores_as_hash
    {
      'V' => visual_score || 0,
      'A' => aural_score || 0,
      'R' => read_score || 0,
      'K' => kinesthetic_score || 0
    }
  end

  def dominant_learning_styles
    scores = scores_as_hash
    max_score = scores.values.max

    dominant_codes = scores.select { |_, score| score == max_score }.keys
    category_names = {
      'V' => 'Visual',
      'A' => 'Auditory',
      'R' => 'Read/Write',
      'K' => 'Kinesthetic'
    }

    dominant_codes.map { |code| category_names[code] }
  end

  def score_for_category(code)
    scores_as_hash[code.upcase]
  end

  def percentage_for_category(code)
    return 0 if total_score.zero?

    score = score_for_category(code)
    ((score.to_f / total_score) * 100).round(1)
  end

  def result_description
    @result_description ||= Vark::ResultDescriptionMatcher.new(dominant_learning_styles, self).call
  end

  def detailed_result_data
    description = result_description

    {
      title: description.title,
      description: description.description,
      characteristics: description.characteristics,
      study_recommendations: description.study_recommendations,
      strengths: description.strengths,
      potential_challenges: description.potential_challenges,
      career_suggestions: description.career_suggestions,
      style_type: description.respond_to?(:style_type) ? description.style_type : 'Unknown',
      learning_styles: description.respond_to?(:learning_styles) ? description.learning_styles : dominant_learning_styles,
      multimodal: description.respond_to?(:multimodal?) ? description.multimodal? : dominant_learning_styles.length > 1,
      score_percentages: {
        visual: percentage_for_category('V'),
        auditory: percentage_for_category('A'),
        read_write: percentage_for_category('R'),
        kinesthetic: percentage_for_category('K')
      }
    }
  end
end
