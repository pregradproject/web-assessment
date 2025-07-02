class Config < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[created_at description id key updated_at value value_type]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  validates :key, presence: true, uniqueness: true
  validates :value, presence: true
  validates :value_type, presence: true, inclusion: { in: %w[string integer float boolean] }

  scope :by_key, ->(key) { where(key: key) }

  before_validation :normalize_key

  def typed_value
    case value_type
    when 'integer'
      value.to_i
    when 'float'
      value.to_f
    when 'boolean'
      ActiveModel::Type::Boolean.new.cast(value)
    else
      value.to_s
    end
  end

  def self.get(key)
    ConfigServices.get(key)
  end

  def self.set(key, value, description: nil, value_type: 'string')
    ConfigServices.set(key, value, description: description, value_type: value_type)
  end

  private

  def normalize_key
    self.key = key.to_s.strip.downcase if key.present?
  end
end
