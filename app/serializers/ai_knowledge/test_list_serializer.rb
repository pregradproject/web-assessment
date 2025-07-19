module AiKnowledge
  class TestListSerializer < ApplicationSerializer
    attributes(
      :id,
      :status,
      :started_at,
      :completed_at,
      :created_at,
      :updated_at
    )

    attribute :question_set do |object|
      if object.ai_knowledge_question_set
        {
          id: object.ai_knowledge_question_set.id,
          name: object.ai_knowledge_question_set.name,
          version: object.ai_knowledge_question_set.version,
          time_limit: object.ai_knowledge_question_set.time_limit
        }
      end
    end

    attribute :results do |object|
      if object.ai_knowledge_result_level
        {
          id: object.ai_knowledge_result_level.id,
          performance_expectancy_score: object.ai_knowledge_result_level.performance_expectancy_score,
          effort_expectancy_score: object.ai_knowledge_result_level.effort_expectancy_score,
          social_influence_score: object.ai_knowledge_result_level.social_influence_score,
          facilitating_conditions_score: object.ai_knowledge_result_level.facilitating_conditions_score,
          hedonic_motivation_score: object.ai_knowledge_result_level.hedonic_motivation_score,
          price_value_score: object.ai_knowledge_result_level.price_value_score,
          habit_score: object.ai_knowledge_result_level.habit_score,
          behavioral_intention_score: object.ai_knowledge_result_level.behavioral_intention_score,
          dominant_learning_styles: object.ai_knowledge_result_level.dominant_learning_styles,
          created_at: object.ai_knowledge_result_level.created_at
        }
      end
    end

    attribute :order do |object|
      if object.order
        {
          id: object.order.id,
          order_number: object.order.order_number,
          status: object.order.status,
          amount: object.order.amount,
          certificate_status: object.order.certificate_status,
          can_download_certificate: object.order.can_download_certificate?,
          created_at: object.order.created_at
        }
      end
    end

    attribute :payment do |object|
      if object.order&.payments&.any?
        payment = object.order.payments.last
        {
          id: payment.id,
          status: payment.status,
          payment_method: payment.payment_method,
          paid_at: payment.paid_at,
          created_at: payment.created_at
        }
      end
    end

    attribute :time_remaining do |object|
      if object.started_at && object.ai_knowledge_question_set&.time_limit && object.ai_knowledge_question_set.time_limit > 0
        end_time = object.started_at + object.ai_knowledge_question_set.time_limit.seconds
        remaining = end_time - Time.current
        remaining > 0 ? remaining.to_i : 0
      else
        nil
      end
    end

    attribute :is_expired do |object|
      if object.started_at && object.ai_knowledge_question_set&.time_limit && object.ai_knowledge_question_set.time_limit > 0
        Time.current > object.started_at + object.ai_knowledge_question_set.time_limit.seconds
      else
        false
      end
    end
  end
end
