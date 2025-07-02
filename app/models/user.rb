class User < ApplicationRecord
  has_secure_password

  include Rails.application.routes.url_helpers

  def self.ransackable_attributes(auth_object = nil)
    %w[birthday created_at email id id_value name phone updated_at]
  end
  def self.ransackable_associations(auth_object = nil)
    %w[avatar_attachment avatar_blob]
  end

  validates :email, presence: true, uniqueness: true

  has_many :vark_tests, dependent: :destroy
  has_many :vark_result_levels, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders

  has_one_attached :avatar

  def avatar_url
    return unless avatar.attached?

    rails_blob_path(avatar, only_path: true, disposition: 'attachment')
  end
end
