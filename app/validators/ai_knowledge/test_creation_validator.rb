module AiKnowledge
  class TestCreationValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :user, :question_set

    def initialize(user, question_set)
      @user = user
      @question_set = question_set
    end

    validate :validate_user_present
    validate :validate_question_set_active
    validate :validate_no_active_test
    validate :validate_questions_exist

    private

    def validate_user_present
      errors.add(:user, 'must be present') unless @user.present?
    end

    def validate_question_set_active
      return unless @question_set.present?

      unless @question_set.active?
        errors.add(:question_set, 'must be active')
      end
    end

    def validate_no_active_test
      return unless @user.present?

      active_test = @user.ai_knowledge_tests.active.first
      if active_test.present?
        errors.add(:user, 'already has an active AI Knowledge test in progress')
      end
    end

    def validate_questions_exist
      return unless @question_set.present?

      if @question_set.total_questions.zero?
        errors.add(:question_set, 'must have questions available')
      end
    end
  end
end
