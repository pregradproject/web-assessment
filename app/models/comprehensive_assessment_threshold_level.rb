class ComprehensiveAssessmentThresholdLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id level_label level_message threshold_min threshold_max created_at updated_at]
  end

  validates :level_label, presence: true
  validates :threshold_min, :threshold_max, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :threshold_max, numericality: { greater_than: :threshold_min }

  scope :ordered, -> { order(:threshold_min) }

  def self.for_score(score)
    where('threshold_min <= ? AND threshold_max >= ?', score, score).first
  end

  def includes_score?(score)
    score >= threshold_min && score <= threshold_max
  end

  def score_range
    "#{threshold_min}-#{threshold_max}"
  end
end
