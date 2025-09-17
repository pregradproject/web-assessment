module Orders
  class CreateOrderServices < ApplicationService
    def initialize(test, amount = nil, coupon_code = nil)
      @test = test
      @amount = amount
      @coupon_code = coupon_code
    end

    def call
      ActiveRecord::Base.transaction do
        create_order
        apply_coupon if @coupon_code.present?
      end

      @order
    end

    private

    def create_order
      test_config = get_test_config(@test)
      original_amount = @amount || test_config[:default_amount]

      @order = @test.create_order(
        user: @test.user,
        amount: original_amount,
        original_amount: original_amount,
        category: test_config[:category],
        description: "#{test_config[:name]} Certificate for #{@test.user.name}"
      )
    end

    def apply_coupon
      coupon_validation = Coupons::ValidateCouponServices.call(@coupon_code, @test.user, @order.amount)

      raise CkvExceptions::UnprocessableEntityError, { coupon_code: [ coupon_validation[:message] ] } unless coupon_validation[:valid]

      Coupons::ApplyCouponServices.call(@order, coupon_validation[:coupon], coupon_validation[:discount_amount])
    end

    def get_test_config(test)
      case test.class.name
      when 'VarkTest'
        {
          category: 'vark_certificate',
          name: 'VARK Learning Style Assessment',
          default_amount: Configs::ConfigServices.vark_price
        }
      when 'AiKnowledgeTest'
        {
          category: 'ai_knowledge_certificate',
          name: 'AI Knowledge Assessment',
          default_amount: Configs::ConfigServices.ai_knowledge_price
        }
      else
        {
          category: 'general_certificate',
          name: 'Assessment',
          default_amount: Configs::ConfigServices.get('general_price', 50000)
        }
      end
    end
  end
end
