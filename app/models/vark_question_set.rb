class VarkQuestionSet < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id version name active created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vark_questions vark_question_set_categories]
  end

  has_many :vark_questions, dependent: :destroy
  has_many :vark_question_set_categories
end
