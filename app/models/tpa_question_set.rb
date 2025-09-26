class TpaQuestionSet < ApplicationRecord
  has_many :tpa_questions, dependent: :destroy
  has_many :tpa_tests, dependent: :destroy

  validates :name, presence: true
  validates :version, presence: true
  validates :time_limit, presence: true, numericality: { greater_than: 0 }

  scope :active_set, -> { where(active: true) }
  scope :by_version, ->(version) { where(version: version) }

  def self.ransackable_attributes(auth_object = nil)
    %w[active created_at id name time_limit updated_at version]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[tpa_questions tpa_tests]
  end

  before_save :ensure_single_active

  def questions_by_category
    tpa_questions.joins(:tpa_category)
                .group('tpa_categories.name')
                .count
  end

  def total_questions
    tpa_questions.count
  end

  private

  def ensure_single_active
    if active? && active_changed?
      TpaQuestionSet.where.not(id: id).update_all(active: false)
    end
  end
end
