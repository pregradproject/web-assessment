class BehavioralLearningQuestionSet < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[completed_at created_at id started_at status updated_at user_id behavioral_learning_question_set_id version name active time_limit]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[behavioral_learning_questions behavioral_learning_question_set_categories behavioral_learning_tests behavioral_learning_categories]
  end

  has_many :behavioral_learning_questions, dependent: :destroy
  has_many :behavioral_learning_tests, dependent: :destroy
  has_many :behavioral_learning_question_set_categories, dependent: :destroy
  has_many :behavioral_learning_categories, through: :behavioral_learning_question_set_categories

  scope :active, -> { where(active: true).order(created_at: :desc) }
  scope :current_active, -> { where(active: true).order(created_at: :desc).first }

  def total_questions
    behavioral_learning_questions.count
  end

  def questions_by_category
    behavioral_learning_questions.includes(:behavioral_learning_category).group_by(&:behavioral_learning_category)
  end
end
