module Tpa
  class SubmitAnswerValidator
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :tpa_test
    attribute :answers, default: []

    validates :tpa_test, presence: true
    validates :answers, presence: true
    validate :test_must_be_in_progress
    validate :test_must_not_be_expired
    validate :answers_must_be_valid_format
    validate :questions_must_belong_to_test
    validate :answers_must_have_valid_options

    def initialize(tpa_test, answers_data)
      @tpa_test = tpa_test
      @answers = Array(answers_data)
      super(tpa_test: @tpa_test, answers: @answers)
    end

    private

    def test_must_be_in_progress
      return unless tpa_test

      unless tpa_test.in_progress?
        errors.add(:tpa_test, 'Test must be in progress to submit answers')
      end
    end

    def test_must_not_be_expired
      return unless tpa_test&.in_progress?

      if tpa_test.expired?
        errors.add(:tpa_test, 'Test has expired and cannot accept new answers')
      end
    end

    def answers_must_be_valid_format
      return if answers.blank?

      answers.each_with_index do |answer, index|
        validate_answer_format(answer, index)
      end
    end

    def validate_answer_format(answer, index)
      unless answer.is_a?(Hash) || answer.respond_to?(:to_h)
        errors.add(:answers, "Answer at position #{index} must be a hash")
        return
      end

      answer_hash = answer.respond_to?(:to_h) ? answer.to_h : answer
      validate_required_keys(answer_hash, index)
    end

    def validate_required_keys(answer_hash, index)
      unless answer_hash.key?(:tpa_question_id) || answer_hash.key?('tpa_question_id')
        errors.add(:answers, "Answer at position #{index} must include tpa_question_id")
      end

      unless answer_hash.key?(:selected_option) || answer_hash.key?('selected_option')
        errors.add(:answers, "Answer at position #{index} must include selected_option")
      end
    end

    def questions_must_belong_to_test
      return unless tpa_test && answers.present?

      test_question_ids = tpa_test.questions.pluck(:id)

      answers.each_with_index do |answer, index|
        answer_hash = answer.respond_to?(:to_h) ? answer.to_h : answer
        question_id = answer_hash[:tpa_question_id] || answer_hash['tpa_question_id']

        next unless question_id

        unless test_question_ids.include?(question_id.to_i)
          errors.add(:answers, "Question at position #{index} does not belong to this test")
        end
      end
    end

    def answers_must_have_valid_options
      return if answers.blank?

      valid_options = %w[A B C D E]

      answers.each_with_index do |answer, index|
        answer_hash = answer.respond_to?(:to_h) ? answer.to_h : answer
        selected_option = answer_hash[:selected_option] || answer_hash['selected_option']

        next unless selected_option

        unless valid_options.include?(selected_option.to_s.upcase)
          errors.add(:answers, "Selected option at position #{index} must be A, B, C, D, or E")
        end
      end
    end
  end
end
