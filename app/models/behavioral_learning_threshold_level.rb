class BehavioralLearningThresholdLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id label message min_threshold max_threshold priority active created_at updated_at]
  end

  validates :label, :message, presence: true
  validates :min_threshold, :max_threshold, presence: true, numericality: true
  validates :priority, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:priority) }

  def self.find_level_for_average(average_score)
    active.ordered.find { |level|
      average_score >= level.min_threshold && average_score <= level.max_threshold
    }
  end

  def range_text
    "#{min_threshold} - #{max_threshold}"
  end
end
