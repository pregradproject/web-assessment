class VarkCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id code name description result_text created_at updated_at]
  end

  has_many :vark_questions, dependent: :destroy
  has_many :vark_test_answers, dependent: :destroy
  has_many :vark_question_set_categories, dependent: :destroy
  has_many :vark_question_sets, through: :vark_question_set_categories

  scope :ordered, -> { order(:code) }

  def self.visual
    find_by(code: 'V')
  end

  def self.aural
    find_by(code: 'A')
  end

  def self.read_write
    find_by(code: 'R')
  end

  def self.kinesthetic
    find_by(code: 'K')
  end
end
