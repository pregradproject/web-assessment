
module Vark
  class SubmitAnswersServices < ApplicationService
    def initialize(vark_test, params, current_user)
      @vark_test = vark_test
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
        question = @vark_test.vark_question_set.vark_questions.find(answer_params[:question_id])
        category = VarkCategory.find(answer_params[:category_id])

        validate_category(question, category)
        validate_point_range(question, answer_params[:point])

        create_answer(question, category, answer_params[:point])
      end
    end

    def validate_category(question, category)
      unless question.vark_category_id == category.id
        raise ActiveRecord::RecordInvalid.new(
          VarkTestAnswer.new.tap { |a| a.errors.add(:base, 'Invalid category for question') }
        )
      end
    end

    def validate_point_range(question, point)
      unless (1..question.max_weight).include?(point.to_i)
        raise ActiveRecord::RecordInvalid.new(
          VarkTestAnswer.new.tap { |a| a.errors.add(:point, "must be between 1 and #{question.max_weight}") }
        )
      end
    end

    def create_answer(question, category, point)
      @vark_test.vark_test_answers.create!(
        vark_question: question,
        vark_category: category,
        point: point,
        answered_at: Time.current
      )
    end

    def mark_test_as_completed
      @vark_test.update!(
        completed_at: Time.current,
        status: :completed
      )
    end

    def calculate_and_save_results
      visual_score = calculate_category_score('V')
      aural_score = calculate_category_score('A')
      read_score = calculate_category_score('R')
      kinesthetic_score = calculate_category_score('K')

      @vark_test.create_vark_result_level!(
        user: @current_user,
        min_score: [ visual_score, aural_score, read_score, kinesthetic_score ].min,
        max_score: [ visual_score, aural_score, read_score, kinesthetic_score ].max,
        visual_score: visual_score,
        aural_score: aural_score,
        read_score: read_score,
        kinesthetic_score: kinesthetic_score
      )
    end

    def calculate_category_score(category_code)
      @vark_test.vark_test_answers
                .joins(:vark_category)
                .where(vark_categories: { code: category_code })
                .sum(:point)
    end
  end
end
