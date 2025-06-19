class VarkCategory < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id code name description result_text created_at updated_at]
  end

  has_many :vark_questions, dependent: :destroy
end
