class ComprehensiveAssessmentResultLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id total_score total_questions average_score level_label level_message created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[comprehensive_assessment_test user]
  end

  belongs_to :comprehensive_assessment_test
  belongs_to :user

  validates :total_score, :total_questions, :average_score, presence: true
  validates :level_label, :level_message, presence: true

  def score_for_category(code)
    comprehensive_assessment_test.comprehensive_assessment_test_answers
                                 .joins(:comprehensive_assessment_category)
                                 .where(comprehensive_assessment_categories: { code: code.upcase })
                                 .sum(:point)
  end

  def category_breakdown
    {
      'CF' => score_for_category('CF'),
      'R' => score_for_category('R'),
      'E' => score_for_category('E'),
      'AG' => score_for_category('AG'),
      'MA' => score_for_category('MA')
    }
  end

  def category_score(code)
    score_for_category(code)
  end

  def category_average(code)
    answers = comprehensive_assessment_test.comprehensive_assessment_test_answers
                                           .joins(:comprehensive_assessment_category)
                                           .where(comprehensive_assessment_categories: { code: code.upcase })

    return 0.0 if answers.count == 0

    answers.average(:point).to_f.round(2)
  end

  def category_averages
    %w[CF R E AG MA].each_with_object({}) do |code, averages|
      averages[code] = category_average(code)
    end
  end

  def strongest_categories
    averages = category_averages
    max_score = averages.values.max

    averages.select { |_, score| score == max_score }.keys.map do |code|
      ComprehensiveAssessmentCategory.find_by(code: code)&.name
    end.compact
  end

  def weakest_categories
    averages = category_averages
    min_score = averages.values.min

    averages.select { |_, score| score == min_score }.keys.map do |code|
      ComprehensiveAssessmentCategory.find_by(code: code)&.name
    end.compact
  end

  def detailed_result_data
    {
      description: '<h3>Comprehensive Assessment Analysis</h3><p>Your comprehensive assessment evaluates your cognitive flexibility, resilience, self-esteem, academic grit, and metacognitive awareness. These dimensions provide insight into your learning capabilities and psychological strengths.</p>',
      study_recommendations: '<p>Focus on leveraging your strongest areas while developing skills in categories that need improvement. Consider strategies that align with your dominant psychological and academic patterns for optimal learning outcomes.</p>'
    }
  end

  def dominant_learning_styles
    strongest_categories
  end
end
