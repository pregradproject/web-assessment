class Order < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :testable, polymorphic: true
  has_many :payments, dependent: :destroy
  has_one :successful_payment, -> { where(status: :settlement) }, class_name: 'Payment'
  has_one_attached :certificate_pdf

  enum :category, {
    vark_certificate: 0,
    general_certificate: 1
  }

  enum :status, {
    pending: 0,
    paid: 1,
    cancelled: 2,
    expired: 3
  }

  enum :certificate_status, {
    pending_generation: 0,
    generating: 1,
    generated: 2,
    generation_failed: 3
  }

  validates :order_number, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true

  before_validation :generate_order_number, on: :create
  before_validation :set_expires_at, on: :create

  scope :active, -> { where(status: [ :pending, :paid ]) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_testable, ->(testable) { where(testable: testable) }

  def paid?
    status == 'paid'
  end

  def expired?
    expires_at && expires_at < Time.current
  end

  def can_download_certificate?
    paid? && testable.completed? && generated?
  end

  def certificate_ready?
    generated? && certificate_pdf.attached?
  end

  def certificate_generating?
    generating?
  end

  def test_type
    testable_type.underscore.gsub('_', ' ').titleize
  end

  def certificate_url
    rails_blob_url(certificate_pdf, only_path: true)
  end

  private

  def generate_order_number
    return if order_number.present?

    loop do
      self.order_number = "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
      break unless Order.exists?(order_number: order_number)
    end
  end

  def set_expires_at
    self.expires_at ||= 24.hours.from_now
  end
end
