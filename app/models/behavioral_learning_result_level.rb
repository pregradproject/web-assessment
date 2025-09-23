class BehavioralLearningResultLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id total_score total_questions average_score level_label level_message created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[behavioral_learning_test user]
  end

  belongs_to :behavioral_learning_test
  belongs_to :user

  validates :total_score, :total_questions, :average_score, presence: true
  validates :level_label, :level_message, presence: true

  def score_for_category(code)
    behavioral_learning_test.behavioral_learning_test_answers
                           .joins(:behavioral_learning_category)
                           .where(behavioral_learning_categories: { code: code.upcase })
                           .sum(:point)
  end

  def category_breakdown
    {
      'M' => score_for_category('M'),
      'A' => score_for_category('A'),
      'H' => score_for_category('H'),
      'R' => score_for_category('R')
    }
  end

  def category_score(code)
    score_for_category(code)
  end

  def category_average(code)
    answers = behavioral_learning_test.behavioral_learning_test_answers
                                     .joins(:behavioral_learning_category)
                                     .where(behavioral_learning_categories: { code: code.upcase })

    return 0.0 if answers.count == 0

    answers.average(:point).to_f.round(2)
  end

  def category_averages
    %w[M A H R].each_with_object({}) do |code, averages|
      averages[code] = category_average(code)
    end
  end

  def strongest_categories
    averages = category_averages
    max_score = averages.values.max

    averages.select { |_, score| score == max_score }.keys.map do |code|
      BehavioralLearningCategory.find_by(code: code)&.name
    end.compact
  end

  def weakest_categories
    averages = category_averages
    min_score = averages.values.min

    averages.select { |_, score| score == min_score }.keys.map do |code|
      BehavioralLearningCategory.find_by(code: code)&.name
    end.compact
  end

  def detailed_result_data
    {
      description: '<h3>Behavioral Learning Analysis</h3><p>Your behavioral learning assessment shows your preferences across Monitoring, Action, Happening, and Reflection categories. These categories help identify how you approach learning and problem-solving in different situations.</p>',
      study_recommendations: '<p>Focus on leveraging your strongest behavioral learning categories while developing skills in areas that need improvement. Consider learning strategies that align with your dominant behavioral patterns.</p>'
    }
  end

  def dominant_learning_styles
    strongest_categories
  end
end
