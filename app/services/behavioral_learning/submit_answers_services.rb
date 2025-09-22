module BehavioralLearning
  class SubmitAnswersServices < ApplicationService
    def initialize(behavioral_learning_test, params, current_user)
      @behavioral_learning_test = behavioral_learning_test
      @params = params
      @current_user = current_user
    end

    def call
      ActiveRecord::Base.transaction do
        process_answers
        calculate_and_save_results
        mark_test_as_completed
      end
    end

    private

    def process_answers
      @params[:answers].each do |answer_params|
        question = @behavioral_learning_test.behavioral_learning_question_set.behavioral_learning_questions.find(answer_params[:question_id])
        category = BehavioralLearningCategory.find(answer_params[:category_id])

        validate_category(question, category)
        validate_point_range(answer_params[:point])

        create_answer(question, category, answer_params[:point])
      end
    end

    def validate_category(question, category)
      unless question.behavioral_learning_category_id == category.id
        raise ActiveRecord::RecordInvalid.new(
          BehavioralLearningTestAnswer.new.tap { |a| a.errors.add(:base, 'Invalid category for question') }
        )
      end
    end

    def validate_point_range(point)
      unless (1..5).include?(point.to_i)
        raise ActiveRecord::RecordInvalid.new(
          BehavioralLearningTestAnswer.new.tap { |a| a.errors.add(:point, 'must be between 1 and 5') }
        )
      end
    end

    def create_answer(question, category, point)
      @behavioral_learning_test.behavioral_learning_test_answers.create!(
        behavioral_learning_question: question,
        behavioral_learning_category: category,
        point: point,
        answered_at: Time.current
      )
    end

    def calculate_and_save_results
      total_score = @behavioral_learning_test.behavioral_learning_test_answers.sum(:point)
      total_questions = @behavioral_learning_test.behavioral_learning_test_answers.count
      average_score = total_questions > 0 ? (total_score.to_f / total_questions).round(2) : 0

      threshold_level = BehavioralLearningThresholdLevel.find_level_for_average(average_score)

      unless threshold_level
        raise ActiveRecord::RecordInvalid.new(
          BehavioralLearningResultLevel.new.tap { |r| r.errors.add(:base, 'No threshold level found for this score') }
        )
      end

      @behavioral_learning_test.create_behavioral_learning_result_level!(
        user: @current_user,
        total_score: total_score,
        total_questions: total_questions,
        average_score: average_score,
        level_label: threshold_level.label,
        level_message: threshold_level.message,
        threshold_min: threshold_level.min_threshold,
        threshold_max: threshold_level.max_threshold
      )
    end

    def mark_test_as_completed
      @behavioral_learning_test.update!(
        completed_at: Time.current,
        status: :completed
      )
    end
  end
end
