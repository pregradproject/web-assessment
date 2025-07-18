class AiKnowledgeResultDescription < ApplicationRecord
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
    4 => 'Quadruple Dominant',
    5 => 'Quintuple Dominant',
    6 => 'Sextuple Dominant',
    7 => 'Septuple Dominant',
    8 => 'Balanced Multimodal'
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
    codes = %w[PE EE SI FC HM PV HT BI]
    patterns = []

    # Single patterns
    patterns += codes

    # Dual patterns
    codes.combination(2).each { |combo| patterns << combo.sort.join }

    # Triple patterns
    codes.combination(3).each { |combo| patterns << combo.sort.join }

    # Quadruple patterns
    codes.combination(4).each { |combo| patterns << combo.sort.join }

    # Quintuple patterns
    codes.combination(5).each { |combo| patterns << combo.sort.join }

    # Sextuple patterns
    codes.combination(6).each { |combo| patterns << combo.sort.join }

    # Septuple patterns
    codes.combination(7).each { |combo| patterns << combo.sort.join }

    # Octuple pattern
    patterns << codes.sort.join

    patterns
  end

  # Get human-readable learning styles from combination pattern
  def learning_styles
    # Handle two-character codes (PE, EE, etc.)
    pattern_codes = combination_pattern.scan(/../)
    pattern_codes.map { |code| code_to_style_name(code) }
  end

  # Check if this is a multimodal learning style (2+ dominant styles)
  def multimodal?
    combination_pattern.length > 2
  end

  # Get the learning style type description
  def style_type
    # Since we have 2-character codes, divide by 2 to get the count
    style_count = combination_pattern.length / 2
    TYPES_BY_LENGTH.fetch(style_count, 'Unknown')
  end

  private

  def normalize_combination_pattern
    return if combination_pattern.blank?

    # Handle two-character codes
    codes = combination_pattern.upcase.scan(/../)
    self.combination_pattern = self.class.normalize_pattern(codes)
  end

  def validate_combination_pattern_format
    return if combination_pattern.blank?

    validate_invalid_codes
    validate_duplicates
    validate_order
  end

  private

  def validate_invalid_codes
    valid_codes = %w[PE EE SI FC HM PV HT BI]
    pattern_codes = combination_pattern.scan(/../)
    invalid_codes = pattern_codes - valid_codes

    if invalid_codes.any?
      errors.add(:combination_pattern, "contains invalid codes: #{invalid_codes.join(', ')}")
    end
  end

  def validate_duplicates
    pattern_codes = combination_pattern.scan(/../)
    if pattern_codes.uniq.length != pattern_codes.length
      errors.add(:combination_pattern, 'cannot contain duplicate codes')
    end
  end

  def validate_order
    pattern_codes = combination_pattern.scan(/../)
    if pattern_codes != pattern_codes.sort
      errors.add(:combination_pattern, 'must be in alphabetical order (BI, EE, FC, HM, HT, PE, PV, SI)')
    end
  end

  # Class methods for code conversion
  def self.style_name_to_code(style_name)
    case style_name.to_s.downcase
    when 'performance expectancy'
      'PE'
    when 'effort expectancy'
      'EE'
    when 'social influence'
      'SI'
    when 'facilitating conditions'
      'FC'
    when 'hedonic motivation'
      'HM'
    when 'price value'
      'PV'
    when 'habit'
      'HT'
    when 'behavioral intention'
      'BI'
    end
  end

  def self.normalize_pattern(codes)
    codes.map(&:upcase).uniq.sort.join
  end

  def code_to_style_name(code)
    case code
    when 'PE'
      'Performance Expectancy'
    when 'EE'
      'Effort Expectancy'
    when 'SI'
      'Social Influence'
    when 'FC'
      'Facilitating Conditions'
    when 'HM'
      'Hedonic Motivation'
    when 'PV'
      'Price Value'
    when 'HT'
      'Habit'
    when 'BI'
      'Behavioral Intention'
    end
  end
end