class TpaResultLevel < ApplicationRecord
  belongs_to :tpa_test

  validates :total_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_questions, presence: true, numericality: { greater_than: 0 }
  validates :average_score, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :level_label, presence: true
  validates :level_message, presence: true

  before_validation :calculate_scores, :determine_level

  def category_scores
    {
      'verbal' => verbal_score,
      'quantitative' => quantitative_score,
      'analytic' => analytic_score,
      'spatial' => spatial_score
    }
  end

  def category_breakdown
    total = category_scores.values.sum
    return {} if total.zero?

    category_scores.transform_values do |score|
      ((score.to_f / total) * 100).round(2)
    end
  end

  def strongest_categories
    max_score = category_scores.values.max
    category_scores.select { |_, score| score == max_score }.keys
  end

  def weakest_categories
    min_score = category_scores.values.min
    category_scores.select { |_, score| score == min_score }.keys
  end

  def detailed_analysis
    {
      'strengths' => analysis_strengths,
      'areas_for_improvement' => analysis_improvements,
      'overall_assessment' => overall_assessment,
      'recommendations' => recommendations
    }
  end

  def test_info
    {
      'test_name' => tpa_test.tpa_question_set.name,
      'test_version' => tpa_test.tpa_question_set.version,
      'completion_date' => tpa_test.completed_at,
      'time_taken' => time_taken_minutes
    }
  end

  private

  def calculate_scores
    return unless tpa_test&.tpa_answers&.any?

    answers = tpa_test.tpa_answers.includes(tpa_question: :tpa_category)

    self.total_questions = tpa_test.questions.count
    self.total_score = answers.correct_answers.count

    # Calculate category-specific scores
    self.verbal_score = answers.by_category('V').correct_answers.count
    self.quantitative_score = answers.by_category('Q').correct_answers.count
    self.analytic_score = answers.by_category('A').correct_answers.count
    self.spatial_score = answers.by_category('S').correct_answers.count

    self.average_score = total_questions > 0 ? (total_score.to_f / total_questions * 100).round(2) : 0.0
  end

  def determine_level
    case average_score
    when 90..100
      self.level_label = 'Excellent'
      self.level_message = 'Outstanding performance across all areas'
    when 80..89
      self.level_label = 'Very Good'
      self.level_message = 'Strong performance with room for minor improvements'
    when 70..79
      self.level_label = 'Good'
      self.level_message = 'Solid performance with some areas for development'
    when 60..69
      self.level_label = 'Fair'
      self.level_message = 'Adequate performance with significant room for improvement'
    else
      self.level_label = 'Needs Improvement'
      self.level_message = 'Consider additional preparation and practice'
    end
  end

  def analysis_strengths
    strongest = strongest_categories
    return [ 'Balanced performance across all categories' ] if strongest.length >= 3

    strongest.map { |cat| "Strong #{cat.humanize.downcase} reasoning abilities" }
  end

  def analysis_improvements
    weakest = weakest_categories
    return [ 'Continue developing all reasoning areas equally' ] if weakest.length >= 3

    weakest.map { |cat| "Focus on improving #{cat.humanize.downcase} reasoning skills" }
  end

  def overall_assessment
    case level_label
    when 'Excellent'
      'Exceptional academic potential with strong reasoning across all domains'
    when 'Very Good'
      'Strong academic potential with well-developed reasoning skills'
    when 'Good'
      'Good academic foundation with potential for further development'
    when 'Fair'
      'Basic academic skills present, additional preparation recommended'
    else
      'Foundational skills need strengthening before advanced academic work'
    end
  end

  def recommendations
    case level_label
    when 'Excellent'
      [ 'Continue challenging yourself with advanced problems', 'Consider tutoring others to reinforce knowledge' ]
    when 'Very Good'
      [ 'Focus on weaker categories while maintaining strengths', 'Practice timed problem-solving' ]
    when 'Good'
      [ 'Regular practice in identified weak areas', 'Seek additional resources for improvement' ]
    when 'Fair'
      [ 'Systematic review of fundamental concepts', 'Consider structured preparation program' ]
    else
      [ 'Basic skill building in all areas', 'Seek personalized tutoring or remedial support' ]
    end
  end

  def time_taken_minutes
    return 0 unless tpa_test.started_at && tpa_test.completed_at

    ((tpa_test.completed_at - tpa_test.started_at) / 60).round(0)
  end
end
