class TpaCategory < ApplicationRecord
  has_many :tpa_questions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, length: { is: 1 }
  validates :description, presence: true

  scope :by_code, ->(code) { where(code: code) }

  def self.ransackable_attributes(auth_object = nil)
    %w[code created_at description id name updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[tpa_questions]
  end

  def self.default_categories
    [
      { name: 'Verbal', code: 'V', description: 'Verbal reasoning and comprehension' },
      { name: 'Quantitative', code: 'Q', description: 'Mathematical and numerical reasoning' },
      { name: 'Analytic', code: 'A', description: 'Logical and analytical thinking' },
      { name: 'Spatial', code: 'S', description: 'Spatial and visual reasoning' }
    ]
  end
end
