class TpaAnswer < ApplicationRecord
  belongs_to :tpa_test
  belongs_to :tpa_question

  validates :selected_option, presence: true, inclusion: { in: %w[A B C D E] }
  validates :is_correct, inclusion: { in: [ true, false ] }
  validates :answered_at, presence: true
  validates :tpa_question_id, uniqueness: { scope: :tpa_test_id }

  scope :correct_answers, -> { where(is_correct: true) }
  scope :incorrect_answers, -> { where(is_correct: false) }
  scope :by_category, ->(category_code) do
    joins(tpa_question: :tpa_category)
      .where(tpa_categories: { code: category_code })
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[answered_at created_at id is_correct selected_option tpa_question_id tpa_test_id updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[tpa_question tpa_test]
  end

  before_validation :set_answered_at, :check_correctness

  def selected_option_text
    tpa_question.options[selected_option]
  end

  def category_name
    tpa_question.tpa_category.name
  end

  private

  def set_answered_at
    self.answered_at = Time.current if answered_at.blank?
  end

  def check_correctness
    self.is_correct = tpa_question.correct_answer == selected_option
  end
end
