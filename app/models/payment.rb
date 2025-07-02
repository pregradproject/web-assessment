class Payment < ApplicationRecord
  belongs_to :order

  enum :status, {
    pending: 0,
    settlement: 1,
    deny: 2,
    cancel: 3,
    expire: 4,
    failure: 5
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :midtrans_order_id, presence: true, uniqueness: true

  before_validation :generate_midtrans_order_id, on: :create
  before_validation :set_expires_at, on: :create

  scope :successful, -> { where(status: :settlement) }

  def success?
    status == 'settlement'
  end

  def expired?
    expires_at && expires_at < Time.current
  end

  private

  def generate_midtrans_order_id
    return if midtrans_order_id.present?

    self.midtrans_order_id = "#{order.order_number}-#{SecureRandom.hex(3).upcase}"
  end

  def set_expires_at
    self.expires_at ||= 24.hours.from_now
  end
end
