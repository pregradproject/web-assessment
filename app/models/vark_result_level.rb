class VarkResultLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id min_score max_score visual_score aural_score read_score kinesthetic_score created_at updated_at]
  end

  belongs_to :vark_test
  belongs_to :user

  def total_score
    visual_score + aural_score + read_score + kinesthetic_score
  end

  def scores_as_hash
    {
      'V' => visual_score,
      'A' => aural_score,
      'R' => read_score,
      'K' => kinesthetic_score
    }
  end

  def dominant_learning_styles
    scores = scores_as_hash
    max_score = scores.values.max

    dominant_codes = scores.select { |_, score| score == max_score }.keys
    category_names = {
      'V' => 'Visual',
      'A' => 'Aural',
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
end
