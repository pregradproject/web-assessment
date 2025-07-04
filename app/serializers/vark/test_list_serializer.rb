module Vark
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
      if object.vark_question_set
        {
          id: object.vark_question_set.id,
          name: object.vark_question_set.name,
          version: object.vark_question_set.version,
          time_limit: object.vark_question_set.time_limit
        }
      end
    end

    attribute :results do |object|
      if object.vark_result_level
        {
          id: object.vark_result_level.id,
          visual_score: object.vark_result_level.visual_score,
          aural_score: object.vark_result_level.aural_score,
          read_score: object.vark_result_level.read_score,
          kinesthetic_score: object.vark_result_level.kinesthetic_score,
          dominant_learning_styles: object.vark_result_level.dominant_learning_styles,
          created_at: object.vark_result_level.created_at
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
      if object.started_at && object.vark_question_set&.time_limit && object.vark_question_set.time_limit > 0
        end_time = object.started_at + object.vark_question_set.time_limit.seconds
        remaining = end_time - Time.current
        remaining > 0 ? remaining.to_i : 0
      else
        nil
      end
    end

    attribute :is_expired do |object|
      if object.started_at && object.vark_question_set&.time_limit && object.vark_question_set.time_limit > 0
        Time.current > object.started_at + object.vark_question_set.time_limit.seconds
      else
        false
      end
    end
  end
end
