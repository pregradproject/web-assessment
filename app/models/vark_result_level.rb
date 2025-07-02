class VarkResultLevel < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[id min_score max_score visual_score aural_score read_score kinesthetic_score created_at updated_at]
  end

  belongs_to :vark_test
  belongs_to :user
end
