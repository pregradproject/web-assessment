class VarkQuestionSet < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[completed_at created_at id started_at status updated_at user_id vark_question_set_id version name active time_limit]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vark_questions vark_question_set_categories vark_tests vark_categories]
  end

  has_many :vark_questions, dependent: :destroy
  has_many :vark_tests, dependent: :destroy
  has_many :vark_question_set_categories, dependent: :destroy
  has_many :vark_categories, through: :vark_question_set_categories

  scope :active, -> { where(active: true) }
  scope :recent, -> { order(version: :desc) }

  def total_questions
    vark_questions.count
  end

  def questions_by_category
    vark_questions.includes(:vark_category).group_by(&:vark_category)
  end
end
