module Tpa
  class PaymentValidator
    include ActiveModel::Validations

    attr_reader :user, :order_id

    def initialize(user, order_id = nil)
      @user = user
      @order_id = order_id
    end

    validates :user, presence: true
    validate :order_must_exist, if: -> { order_id.present? }
    validate :order_must_belong_to_user, if: -> { order_id.present? && order.present? }
    validate :order_must_be_paid, if: -> { order_id.present? && order.present? }
    validate :order_must_be_tpa_category, if: -> { order_id.present? && order.present? }
    validate :order_must_not_have_test, if: -> { order_id.present? && order.present? }
    validate :user_must_have_tpa_order, if: -> { order_id.blank? }

    def valid?
      super
    end

    def errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def valid_order
      return nil unless valid?

      @valid_order ||= order_id.present? ? order : find_user_tpa_order
    end

    private

    def order
      @order ||= Order.find_by(id: order_id)
    end

    def find_user_tpa_order
      @user_tpa_order ||= Order.for_user(@user)
                             .where(category: :tpa_certificate, status: :paid)
                             .where.missing(:testable)
                             .first
    end

    def order_must_exist
      return unless order_id.present?

      errors.add(:order_id, 'not found') unless order.present?
    end

    def order_must_belong_to_user
      return unless order.present?

      errors.add(:order_id, 'does not belong to current user') unless order.user_id == user.id
    end

    def order_must_be_paid
      return unless order.present?

      errors.add(:order_id, 'must be paid') unless order.paid?
    end

    def order_must_be_tpa_category
      return unless order.present?

      errors.add(:order_id, 'must be a TPA certificate order') unless order.tpa_certificate?
    end

    def order_must_not_have_test
      return unless order.present?

      errors.add(:order_id, 'already associated with a test') if order.testable.present?
    end

    def user_must_have_tpa_order
      return unless order_id.blank?

      errors.add(:base, 'No valid TPA order found. Please purchase a TPA assessment first.') unless find_user_tpa_order.present?
    end
  end
end
