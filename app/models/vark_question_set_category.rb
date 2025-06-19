class VarkQuestionSetCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id active created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vark_category vark_question_set]
  end

  belongs_to :vark_question_set
  belongs_to :vark_category
end
