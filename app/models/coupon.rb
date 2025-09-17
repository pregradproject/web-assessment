class Coupon < ApplicationRecord
  def self.ransackable_associations(auth_object = nil)
    %w[coupon_usages orders]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[active code created_at description discount_type discount_value expiry_date id max_uses_per_user name updated_at]
  end

  has_many :coupon_usages, dependent: :destroy
  has_many :orders, dependent: :nullify
  has_many :users, through: :coupon_usages

  enum :discount_type, {
    percentage: 0,
    fixed: 1
  }

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :discount_type, presence: true
  validates :discount_value, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :max_uses_per_user, presence: true, numericality: { greater_than_or_equal_to: 1 }

  validate :validate_discount_value_for_type
  validate :validate_expiry_date_future

  before_validation :normalize_code

  scope :active, -> { where(active: true) }
  scope :valid_for_use, -> { active.where('expiry_date IS NULL OR expiry_date > ?', Time.current) }

  def valid_for_user?(user)
    return false unless active?
    return false if expired?
    return false if user_usage_exceeded?(user)

    true
  end

  def usage_count_for_user(user)
    coupon_usages.where(user: user).count
  end

  def expired?
    expiry_date && expiry_date < Time.current
  end

  def calculate_discount(amount)
    case discount_type
    when 'percentage'
      (amount * discount_value / 100).round(2)
    when 'fixed'
      [ discount_value, amount ].min
    else
      0
    end
  end

  def display_discount
    case discount_type
    when 'percentage'
      "#{discount_value.to_i}%"
    when 'fixed'
      "Rp #{discount_value.to_i}"
    end
  end

  private

  def normalize_code
    self.code = code&.upcase&.strip
  end

  def validate_discount_value_for_type
    return unless discount_type && discount_value

    case discount_type
    when 'percentage'
      unless discount_value >= 0.01 && discount_value <= 100
        errors.add(:discount_value, 'must be between 0.01 and 100 for percentage discount')
      end
    when 'fixed'
      errors.add(:discount_value, 'must be greater than or equal to 0.01') unless discount_value >= 0.01
    end
  end

  def validate_expiry_date_future
    return unless expiry_date

    errors.add(:expiry_date, 'must be in the future') if expiry_date <= Time.current
  end

  def user_usage_exceeded?(user)
    usage_count_for_user(user) >= max_uses_per_user
  end
end
