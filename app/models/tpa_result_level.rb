class TpaResultLevel < ApplicationRecord
  belongs_to :tpa_test

  validates :total_score, presence: true, numericality: { greater_than_or_equal_to: 200, less_than_or_equal_to: 800 }
  validates :total_questions, presence: true, numericality: { greater_than: 0 }
  validates :average_score, presence: true, numericality: { greater_than_or_equal_to: 200, less_than_or_equal_to: 800 }
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

  def dominant_learning_styles
    strongest_categories.map { |category| category.humanize }
  end

  def overall_assessment
    assessment_messages[level_label] || assessment_messages['default']
  end

  def recommendations
    recommendation_lists[level_label] || recommendation_lists['default']
  end

  def detailed_result_data
    {
      description: level_message,
      study_recommendations: recommendations,
      overall_assessment: overall_assessment,
      strongest_categories: strongest_categories,
      weakest_categories: weakest_categories,
      analysis_strengths: analysis_strengths,
      analysis_improvements: analysis_improvements
    }
  end

  def time_taken_minutes
    return 0 unless tpa_test.started_at && tpa_test.completed_at

    ((tpa_test.completed_at - tpa_test.started_at) / 60).round(0)
  end

  private

  def calculate_scores
    return unless tpa_test&.tpa_answers&.any?

    answers = tpa_test.tpa_answers.includes(tpa_question: :tpa_category)

    self.total_questions = tpa_test.questions.count
    correct_answers = answers.correct_answers.count

    # Calculate category-specific scores
    self.verbal_score = answers.by_category('V').correct_answers.count
    self.quantitative_score = answers.by_category('Q').correct_answers.count
    self.analytic_score = answers.by_category('A').correct_answers.count
    self.spatial_score = answers.by_category('S').correct_answers.count

    # Calculate total score using new formula: (benar / total soal x 600) + 200
    self.total_score = total_questions > 0 ? ((correct_answers.to_f / total_questions) * 600 + 200).round : 200

    # Average score is now the total score (since it's calculated on 200-800 scale)
    self.average_score = total_score
  end

  def determine_level
    label, message = level_for_score(average_score)
    self.level_label = label
    self.level_message = message
  end

  def level_for_score(score)
    score_levels = Configs::ConfigServices.tpa_score_levels

    score_levels.each do |level_key, level_config|
      if score >= level_config['min_score'] && score <= level_config['max_score']
        return [ level_config['label'], level_config['message'] ]
      end
    end

    # Fallback if no range matches
    [ 'Tidak Diketahui', 'Skor tidak sesuai dengan kategori yang ditentukan' ]
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

  def assessment_messages
    {
      'Kategori Tinggi' => 'Potensi akademik yang sangat baik dengan penalaran kuat di semua domain',
      'Kategori Rata-Rata' => 'Potensi akademik yang baik dengan keterampilan penalaran yang berkembang dengan baik',
      'Kategori Rendah' => 'Dasar akademik yang baik dengan potensi untuk pengembangan lebih lanjut',
      'default' => 'Keterampilan dasar perlu diperkuat sebelum pekerjaan akademik tingkat lanjut'
    }
  end

  def recommendation_lists
    {
      'Kategori Tinggi' => [ 'Terus menantikan diri dengan masalah-masalah tingkat lanjut', 'Pertimbangkan untuk membimbing orang lain untuk memperkuat pengetahuan' ],
      'Kategori Rata-Rata' => [ 'Fokus pada kategori yang lebih lemah sambil mempertahankan kekuatan', 'Berlatih pemecahan masalah dengan waktu terbatas' ],
      'Kategori Rendah' => [ 'Latihan teratur di area-area lemah yang diidentifikasi', 'Cari sumber daya tambahan untuk perbaikan' ],
      'default' => [ 'Membangun keterampilan dasar di semua area', 'Cari bantuan tutorial atau dukungan remedial yang dipersonalisasi' ]
    }
  end
end
