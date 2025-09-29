require 'ostruct'

module ComprehensiveAssessment
  class SubmitAnswersServices < ApplicationService
    def initialize(comprehensive_assessment_test, params, current_user)
      @comprehensive_assessment_test = comprehensive_assessment_test
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
        question = @comprehensive_assessment_test.comprehensive_assessment_question_set.comprehensive_assessment_questions.find(answer_params[:question_id])
        category = ComprehensiveAssessmentCategory.find(answer_params[:category_id])

        validate_category(question, category)
        validate_point_range(answer_params[:point])

        create_answer(question, category, answer_params[:point])
      end
    end

    def validate_category(question, category)
      unless question.comprehensive_assessment_category_id == category.id
        raise ActiveRecord::RecordInvalid.new(
          ComprehensiveAssessmentTestAnswer.new.tap { |a| a.errors.add(:base, 'Invalid category for question') }
        )
      end
    end

    def validate_point_range(point)
      unless (1..5).include?(point.to_i)
        raise ActiveRecord::RecordInvalid.new(
          ComprehensiveAssessmentTestAnswer.new.tap { |a| a.errors.add(:point, 'must be between 1 and 5') }
        )
      end
    end

    def create_answer(question, category, point)
      @comprehensive_assessment_test.comprehensive_assessment_test_answers.create!(
        comprehensive_assessment_question: question,
        comprehensive_assessment_category: category,
        point: point,
        answered_at: Time.current
      )
    end

    def calculate_and_save_results
      total_score = @comprehensive_assessment_test.comprehensive_assessment_test_answers.sum(:point)
      total_questions = @comprehensive_assessment_test.comprehensive_assessment_test_answers.count
      average_score = total_questions > 0 ? (total_score.to_f / total_questions).round(2) : 0

      threshold_level = ComprehensiveAssessmentThresholdLevel.for_score(average_score)

      unless threshold_level
        # Create a default threshold level if none exists
        threshold_level = OpenStruct.new(
          level_label: 'Developing',
          level_message: 'Your comprehensive assessment shows developing capabilities across multiple dimensions.',
          threshold_min: 0,
          threshold_max: 100
        )
      end

      @comprehensive_assessment_test.create_comprehensive_assessment_result_level!(
        user: @current_user,
        total_score: total_score,
        total_questions: total_questions,
        average_score: average_score,
        level_label: threshold_level.level_label,
        level_message: threshold_level.level_message,
        threshold_min: threshold_level.threshold_min,
        threshold_max: threshold_level.threshold_max
      )
    end

    def mark_test_as_completed
      @comprehensive_assessment_test.update!(
        completed_at: Time.current,
        status: :completed
      )
    end
  end
end
