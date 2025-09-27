class TpaTest < ApplicationRecord
  belongs_to :user
  belongs_to :tpa_question_set
  has_many :tpa_answers, dependent: :destroy
  has_one :tpa_result_level, dependent: :destroy
  has_one :order, as: :testable, dependent: :destroy

  enum :status, { in_progress: 0, completed: 1, expired: 2 }

  validates :status, presence: true
  validates :started_at, presence: true, if: :in_progress?

  scope :by_user, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where(status: :in_progress) }

  def self.ransackable_attributes(auth_object = nil)
    %w[completed_at created_at id started_at status tpa_question_set_id updated_at user_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[order tpa_answers tpa_question_set tpa_result_level user]
  end

  before_create :set_started_at

  def time_remaining
    return 0 unless in_progress? && started_at

    time_limit_seconds = tpa_question_set.time_limit * 60
    elapsed_seconds = Time.current - started_at
    remaining = time_limit_seconds - elapsed_seconds

    [ remaining.to_i, 0 ].max
  end

  def expired?
    time_remaining <= 0 && in_progress?
  end

  def questions
    tpa_question_set.tpa_questions.includes(:tpa_category)
  end

  def answered_questions
    tpa_answers.includes(:tpa_question)
  end

  def completion_percentage
    return 0 if questions.count.zero?

    (answered_questions.count.to_f / questions.count * 100).round(2)
  end

  def mark_as_expired!
    update!(status: :expired, completed_at: Time.current) if expired?
  end

  def complete_test!
    update!(status: :completed, completed_at: Time.current)
  end

  private

  def set_started_at
    self.started_at = Time.current if in_progress?
  end
end
