class User < ApplicationRecord
  has_secure_password

  include Rails.application.routes.url_helpers

  def self.ransackable_attributes(auth_object = nil)
    %w[birthday created_at email id id_value name phone updated_at google_id auth_provider google_email]
  end
  def self.ransackable_associations(auth_object = nil)
    %w[avatar_attachment avatar_blob]
  end

  validates :email, presence: true, uniqueness: true
  validates :google_id, uniqueness: { allow_blank: true }
  validates :auth_provider, presence: true, inclusion: { in: %w[email google both] }

  has_many :vark_tests, dependent: :destroy
  has_many :vark_result_levels, dependent: :destroy
  has_many :ai_knowledge_tests, dependent: :destroy
  has_many :ai_knowledge_result_levels, dependent: :destroy
  has_many :behavioral_learning_tests, dependent: :destroy
  has_many :behavioral_learning_result_levels, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders

  has_one_attached :avatar

  scope :with_reset_token, ->(token) { where(reset_password_token: token) }

  def avatar_url
    return unless avatar.attached?

    rails_blob_path(avatar, only_path: true, disposition: 'attachment')
  end

  def generate_reset_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.current
    save!
  end

  def reset_password_token_valid?
    reset_password_sent_at && reset_password_sent_at > 1.hour.ago
  end

  def reset_password!(new_password)
    self.password = new_password
    self.reset_password_token = nil
    self.reset_password_sent_at = nil
    save!
  end
end
