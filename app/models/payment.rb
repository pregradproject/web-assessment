class Payment < ApplicationRecord
  def self.ransackable_associations(auth_object = nil)
    [ 'order' ]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[amount created_at expires_at id id_value midtrans_order_id midtrans_response midtrans_transaction_id order_id paid_at payment_method snap_token status updated_at]
  end

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
