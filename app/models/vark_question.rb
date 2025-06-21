class VarkQuestion < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id body created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[vark_category vark_question_set]
  end

  belongs_to :vark_question_set
  belongs_to :vark_category
  has_many :vark_test_answers, dependent: :destroy

  scope :by_category, ->(category) { where(vark_category: category) }
  scope :ordered, -> { order(:created_at) }
end
