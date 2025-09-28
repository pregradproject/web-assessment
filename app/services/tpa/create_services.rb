module Tpa
  class CreateServices < ApplicationService
    def initialize(user, tpa_question_set_id, order_id = nil)
      @user = user
      @tpa_question_set_id = tpa_question_set_id
      @order_id = order_id
    end

    def call
      validate_payment
      create_test
      link_order_to_test
      @tpa_test
    end

    private

    attr_reader :user, :tpa_question_set_id, :tpa_question_set, :tpa_test, :order_id

    def validate_payment
      payment_validator = Tpa::PaymentValidator.new(user, order_id)
      raise CkvExceptions::UnprocessableEntityError, payment_validator.errors.full_messages unless payment_validator.valid?

      @valid_order = payment_validator.valid_order
    end

    def create_test
      @tpa_question_set = TpaQuestionSet.find(@tpa_question_set_id)

      @tpa_test = @user.tpa_tests.create!(
        tpa_question_set: @tpa_question_set,
        status: :in_progress,
        started_at: Time.current
      )
    end

    def link_order_to_test
      return unless @valid_order.present?

      @valid_order.update!(testable: @tpa_test)
    end
  end
end
