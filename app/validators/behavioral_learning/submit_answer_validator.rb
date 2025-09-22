module BehavioralLearning
  class SubmitAnswerValidator
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :answers, :behavioral_learning_test

    def initialize(params, behavioral_learning_test)
      @answers = params[:answers]
      @behavioral_learning_test = behavioral_learning_test
    end

    validate :validate_answers_array
    validate :validate_answer_count
    validate :validate_answer_fields
    validate :validate_point_range
    validate :validate_questions_exist
    validate :validate_categories_exist
    validate :validate_no_duplicate_questions

    private

    def validate_answers_array
      unless @answers.is_a?(Array) && @answers.present?
        errors.add(:answers, 'must be provided as an array')
      end
    end

    def validate_answer_count
      return unless errors.empty?

      expected_question_count = @behavioral_learning_test.behavioral_learning_question_set.behavioral_learning_questions.count
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

    def validate_point_range
      return unless errors.empty?

      @answers.each_with_index do |answer, index|
        point = answer[:point].to_i
        unless (1..5).include?(point)
          errors.add(:answers, "Answer #{index + 1} point must be between 1 and 5, got #{point}")
        end
      end
    end

    def validate_questions_exist
      return unless errors.empty?

      question_set = @behavioral_learning_test.behavioral_learning_question_set
      valid_question_ids = question_set.behavioral_learning_questions.pluck(:id)

      @answers.each_with_index do |answer, index|
        unless valid_question_ids.include?(answer[:question_id])
          errors.add(:answers, "Answer #{index + 1} references an invalid question ID: #{answer[:question_id]}")
        end
      end
    end

    def validate_categories_exist
      return unless errors.empty?

      valid_category_ids = BehavioralLearningCategory.pluck(:id)

      @answers.each_with_index do |answer, index|
        unless valid_category_ids.include?(answer[:category_id])
          errors.add(:answers, "Answer #{index + 1} references an invalid category ID: #{answer[:category_id]}")
        end
      end
    end

    def validate_no_duplicate_questions
      return unless errors.empty?

      question_ids = @answers.map { |a| a[:question_id] }
      duplicates = question_ids.select { |id| question_ids.count(id) > 1 }.uniq

      if duplicates.any?
        errors.add(:answers, "Duplicate question IDs found: #{duplicates.join(', ')}")
      end
    end
  end
end