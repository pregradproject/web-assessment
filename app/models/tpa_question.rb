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

  def self.ransackable_attributes(auth_object = nil)
    %w[correct_answer created_at difficulty_level explanation id option_a option_b option_c option_d option_e question_text tpa_category_id tpa_question_set_id updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[image_attachment image_blob tpa_answers tpa_category tpa_question_set]
  end

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
