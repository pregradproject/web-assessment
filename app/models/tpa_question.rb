class TpaQuestion < ApplicationRecord
  belongs_to :tpa_category
  belongs_to :tpa_question_set
  has_many :tpa_answers, dependent: :destroy

  has_one_attached :image

  validates :question_text, presence: true
  validates :option_a, presence: true
  validates :option_b, presence: true
  validates :option_c, presence: true
  validates :option_d, presence: true
  validates :option_e, presence: true
  validates :correct_answer, presence: true, inclusion: { in: %w[A B C D E] }
  validates :explanation, presence: true
  validates :difficulty_level, presence: true, numericality: { in: 1..5 }

  scope :by_category, ->(category) { joins(:tpa_category).where(tpa_categories: { code: category }) }
  scope :by_difficulty, ->(level) { where(difficulty_level: level) }
  scope :random_order, -> { order('RANDOM()') }

  def options
    {
      'A' => option_a,
      'B' => option_b,
      'C' => option_c,
      'D' => option_d,
      'E' => option_e
    }
  end

  def correct_option_text
    options[correct_answer]
  end

  def category_name
    tpa_category.name
  end
end
