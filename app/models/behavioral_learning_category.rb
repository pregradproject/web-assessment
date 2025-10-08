class BehavioralLearningCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id code name description created_at updated_at]
  end

  has_many :behavioral_learning_questions, dependent: :destroy
  has_many :behavioral_learning_test_answers, dependent: :destroy
  has_many :behavioral_learning_question_set_categories, dependent: :destroy
  has_many :behavioral_learning_question_sets, through: :behavioral_learning_question_set_categories

  validates :code, presence: true, uniqueness: true, inclusion: { in: %w[OBS SRL GOL OUT] }
  validates :name, presence: true

  scope :ordered, -> { order(:code) }

  def self.observation
    find_by(code: 'OBS')
  end

  def self.self_regulation
    find_by(code: 'SRL')
  end

  def self.goal_setting
    find_by(code: 'GOL')
  end

  def self.learning_outcomes
    find_by(code: 'OUT')
  end
end
