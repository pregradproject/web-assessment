class VarkResultDescription < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[active career_suggestions characteristics combination_pattern created_at description id id_value potential_challenges strengths study_recommendations title updated_at]
  end

  validates :combination_pattern, presence: true, uniqueness: true
  validates :title, presence: true
  validates :description, presence: true
  validates :active, inclusion: { in: [ true, false ] }

  validate :validate_combination_pattern_format

  scope :active, -> { where(active: true) }

  before_validation :normalize_combination_pattern

  TYPES_BY_LENGTH = {
    1 => 'Single Dominant',
    2 => 'Dual Dominant',
    3 => 'Triple Dominant',
    4 => 'Balanced Multimodal'
  }.freeze

  # Class method to find description by dominant learning styles array
  def self.find_by_dominant_styles(dominant_styles)
    return nil if dominant_styles.blank?

    # Convert style names to codes and normalize pattern
    codes = dominant_styles.map { |style| style_name_to_code(style) }.compact
    pattern = normalize_pattern(codes)

    active.find_by(combination_pattern: pattern)
  end

  # Class method to get all possible combination patterns
  def self.all_possible_patterns
    codes = %w[V A R K]
    patterns = []

    # Single patterns
    patterns += codes

    # Dual patterns
    codes.combination(2).each { |combo| patterns << combo.sort.join }

    # Triple patterns
    codes.combination(3).each { |combo| patterns << combo.sort.join }

    # Quadruple pattern
    patterns << codes.sort.join

    patterns
  end

  # Get human-readable learning styles from combination pattern
  def learning_styles
    combination_pattern.chars.map { |code| code_to_style_name(code) }
  end

  # Check if this is a multimodal learning style (2+ dominant styles)
  def multimodal?
    combination_pattern.length > 1
  end

  # Get the learning style type description
  def style_type
    TYPES_BY_LENGTH.fetch(combination_pattern.length, 'Unknown')
  end

  private

  def normalize_combination_pattern
    return if combination_pattern.blank?

    self.combination_pattern = self.class.normalize_pattern(combination_pattern.upcase.chars)
  end

  def validate_combination_pattern_format
    return if combination_pattern.blank?

    validate_invalid_codes
    validate_duplicates
    validate_order
  end

  private

  def validate_invalid_codes
    valid_codes = %w[V A R K]
    pattern_codes = combination_pattern.chars
    invalid_codes = pattern_codes - valid_codes

    if invalid_codes.any?
      errors.add(:combination_pattern, "contains invalid codes: #{invalid_codes.join(', ')}")
    end
  end

  def validate_duplicates
    pattern_codes = combination_pattern.chars
    if pattern_codes.uniq.length != pattern_codes.length
      errors.add(:combination_pattern, 'cannot contain duplicate codes')
    end
  end

  def validate_order
    pattern_codes = combination_pattern.chars
    if pattern_codes != pattern_codes.sort
      errors.add(:combination_pattern, 'must be in alphabetical order (A, K, R, V)')
    end
  end

  # Class methods for code conversion
  def self.style_name_to_code(style_name)
    case style_name.to_s.downcase
    when 'visual'
      'V'
    when 'auditory', 'aural'
      'A'
    when 'read/write', 'reading'
      'R'
    when 'kinesthetic'
      'K'
    end
  end

  def self.normalize_pattern(codes)
    codes.map(&:upcase).uniq.sort.join
  end

  def code_to_style_name(code)
    case code
    when 'V'
      'Visual'
    when 'A'
      'Auditory'
    when 'R'
      'Read/Write'
    when 'K'
      'Kinesthetic'
    end
  end
end
