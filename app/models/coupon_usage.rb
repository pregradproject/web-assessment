class CouponUsage < ApplicationRecord
  def self.ransackable_associations(auth_object = nil)
    %w[coupon order user]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[coupon_id created_at discount_amount id order_id updated_at used_at user_id]
  end

  belongs_to :coupon
  belongs_to :user
  belongs_to :order

  validates :used_at, presence: true
  validates :discount_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_id, uniqueness: true

  scope :for_user, ->(user) { where(user: user) }
  scope :for_coupon, ->(coupon) { where(coupon: coupon) }
  scope :recent, -> { order(created_at: :desc) }

  def coupon_code
    coupon&.code
  end

  def user_name
    user&.name
  end

  def order_number
    order&.order_number
  end
end
