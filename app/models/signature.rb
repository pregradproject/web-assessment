class Signature < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id name department status created_at updated_at]
  end
  def self.ransackable_associations(auth_object = nil)
    %w[signature_image_attachment signature_image_blob]
  end

  has_one_attached :signature_image

  enum :status, { inactive: 0, active: 1 }, default: :inactive
end
