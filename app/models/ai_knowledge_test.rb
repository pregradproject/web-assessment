class AiKnowledgeTest < ApplicationRecord
  def self.ransackable_attributes(auth_object = nil)
    %w[completed_at created_at id started_at status updated_at user_id ai_knowledge_question_set_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[order user ai_knowledge_question_set ai_knowledge_result_level ai_knowledge_test_answers]
  end

  belongs_to :user
  belongs_to :ai_knowledge_question_set
  has_many :ai_knowledge_test_answers, dependent: :destroy
  has_one :ai_knowledge_result_level, dependent: :destroy
  has_one :order, as: :testable, dependent: :destroy

  enum :status, { in_progress: 0, completed: 1, expired: 2 }

  validates :started_at, presence: true, if: :in_progress?
  validates :completed_at, presence: true, if: :completed?

  scope :active, -> { where(status: [ :in_progress, :completed ]) }
  scope :recent, -> { order(created_at: :desc) }

  def time_remaining
    return 0 unless started_at && ai_knowledge_question_set.time_limit.positive?

    elapsed = Time.current - started_at
    remaining = ai_knowledge_question_set.time_limit.minutes - elapsed.to_i
    [ remaining, 0 ].max
  end

  def expired?
    return false unless started_at && ai_knowledge_question_set.time_limit.positive?

    Time.current > started_at + ai_knowledge_question_set.time_limit.minutes
  end
end
