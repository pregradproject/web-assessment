module AiKnowledge
  class SubmitAnswersServices < ApplicationService
    def initialize(ai_knowledge_test, params, current_user)
      @ai_knowledge_test = ai_knowledge_test
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
        question = @ai_knowledge_test.ai_knowledge_question_set.ai_knowledge_questions.find(answer_params[:question_id])
        category = AiKnowledgeCategory.find(answer_params[:category_id])

        validate_category(question, category)
        validate_point_range(question, answer_params[:point])

        create_answer(question, category, answer_params[:point])
      end
    end

    def validate_category(question, category)
      unless question.ai_knowledge_category_id == category.id
        raise ActiveRecord::RecordInvalid.new(
          AiKnowledgeTestAnswer.new.tap { |a| a.errors.add(:base, 'Invalid category for question') }
        )
      end
    end

    def validate_point_range(question, point)
      unless (1..question.max_weight).include?(point.to_i)
        raise ActiveRecord::RecordInvalid.new(
          AiKnowledgeTestAnswer.new.tap { |a| a.errors.add(:point, "must be between 1 and #{question.max_weight}") }
        )
      end
    end

    def create_answer(question, category, point)
      @ai_knowledge_test.ai_knowledge_test_answers.create!(
        ai_knowledge_question: question,
        ai_knowledge_category: category,
        point: point,
        answered_at: Time.current
      )
    end

    def mark_test_as_completed
      @ai_knowledge_test.update!(
        completed_at: Time.current,
        status: :completed
      )
    end

    def calculate_and_save_results
      pe_score = calculate_category_score('PE')
      ee_score = calculate_category_score('EE')
      si_score = calculate_category_score('SI')
      fc_score = calculate_category_score('FC')
      hm_score = calculate_category_score('HM')
      pv_score = calculate_category_score('PV')
      ht_score = calculate_category_score('HT')
      bi_score = calculate_category_score('BI')

      scores = [ pe_score, ee_score, si_score, fc_score, hm_score, pv_score, ht_score, bi_score ]

      @ai_knowledge_test.create_ai_knowledge_result_level!(
        user: @current_user,
        min_score: scores.min,
        max_score: scores.max,
        performance_expectancy_score: pe_score,
        effort_expectancy_score: ee_score,
        social_influence_score: si_score,
        facilitating_conditions_score: fc_score,
        hedonic_motivation_score: hm_score,
        price_value_score: pv_score,
        habit_score: ht_score,
        behavioral_intention_score: bi_score
      )
    end

    def calculate_category_score(category_code)
      @ai_knowledge_test.ai_knowledge_test_answers
                        .joins(:ai_knowledge_category)
                        .where(ai_knowledge_categories: { code: category_code })
                        .sum(:point)
    end
  end
end
