class TpaResultLevel < ApplicationRecord
  belongs_to :tpa_test

  validates :total_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_questions, presence: true, numericality: { greater_than: 0 }
  validates :average_score, presence: true, numericality: { greater_than_or_equal_to: 0.0 }
  validates :level_label, presence: true
  validates :level_message, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[analytic_score average_score created_at id level_label level_message quantitative_score spatial_score total_questions total_score tpa_test_id updated_at verbal_score]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[tpa_test]
  end

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
    label, message = level_for_score(average_score)
    self.level_label = label
    self.level_message = message
  end

  def level_for_score(score)
    case score
    when 90..100 then [ 'Excellent', 'Outstanding performance across all areas' ]
    when 80..89 then [ 'Very Good', 'Strong performance with room for minor improvements' ]
    when 70..79 then [ 'Good', 'Solid performance with some areas for development' ]
    when 60..69 then [ 'Fair', 'Adequate performance with significant room for improvement' ]
    else [ 'Needs Improvement', 'Consider additional preparation and practice' ]
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
    assessment_messages[level_label] || assessment_messages['default']
  end

  def assessment_messages
    {
      'Excellent' => 'Exceptional academic potential with strong reasoning across all domains',
      'Very Good' => 'Strong academic potential with well-developed reasoning skills',
      'Good' => 'Good academic foundation with potential for further development',
      'Fair' => 'Basic academic skills present, additional preparation recommended',
      'default' => 'Foundational skills need strengthening before advanced academic work'
    }
  end

  def recommendations
    recommendation_lists[level_label] || recommendation_lists['default']
  end

  def recommendation_lists
    {
      'Excellent' => [ 'Continue challenging yourself with advanced problems', 'Consider tutoring others to reinforce knowledge' ],
      'Very Good' => [ 'Focus on weaker categories while maintaining strengths', 'Practice timed problem-solving' ],
      'Good' => [ 'Regular practice in identified weak areas', 'Seek additional resources for improvement' ],
      'Fair' => [ 'Systematic review of fundamental concepts', 'Consider structured preparation program' ],
      'default' => [ 'Basic skill building in all areas', 'Seek personalized tutoring or remedial support' ]
    }
  end

  def time_taken_minutes
    return 0 unless tpa_test.started_at && tpa_test.completed_at

    ((tpa_test.completed_at - tpa_test.started_at) / 60).round(0)
  end
end
