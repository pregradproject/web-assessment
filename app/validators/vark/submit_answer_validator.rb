module Vark
  class SubmitAnswerValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :answers, :vark_test

    def initialize(params, vark_test)
      @answers = params[:answers]
      @vark_test = vark_test
    end

    validate :validate_answers_array
    validate :validate_answer_count
    validate :validate_answer_fields

    private

    def validate_answers_array
      unless @answers.is_a?(Array) && @answers.present?
        errors.add(:answers, 'must be provided as an array')
      end
    end

    def validate_answer_count
      return unless errors.empty?

      expected_question_count = @vark_test.vark_question_set.vark_questions.count
      if @answers.length != expected_question_count
        errors.add(:answers, "All #{expected_question_count} questions must be answered")
      end
    end

    def validate_answer_fields
      return unless errors.empty?

      @answers.each_with_index do |answer, index|
        unless answer[:question_id].present? && answer[:category_id].present? && answer[:point].present?
          missing_fields = []
          missing_fields << 'question_id' unless answer[:question_id].present?
          missing_fields << 'category_id' unless answer[:category_id].present?
          missing_fields << 'point' unless answer[:point].present?

          errors.add(:answers, "Answer #{index + 1} is missing required fields (#{missing_fields.join(', ')})")
        end
      end
    end
  end
end
