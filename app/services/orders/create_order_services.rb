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
      test_configs[test.class.name] || default_test_config
    end

    private

    def test_configs
      {
        'VarkTest' => vark_config,
        'AiKnowledgeTest' => ai_knowledge_config,
        'BehavioralLearningTest' => behavioral_learning_config,
        'ComprehensiveAssessmentTest' => comprehensive_assessment_config,
        'TpaTest' => tpa_config
      }
    end

    def vark_config
      {
        category: 'vark_certificate',
        name: 'VARK Learning Style Assessment',
        default_amount: Configs::ConfigServices.vark_price
      }
    end

    def ai_knowledge_config
      {
        category: 'ai_knowledge_certificate',
        name: 'AI Knowledge Assessment',
        default_amount: Configs::ConfigServices.ai_knowledge_price
      }
    end

    def behavioral_learning_config
      {
        category: 'behavioral_learning_certificate',
        name: 'Behavioral Learning Assessment',
        default_amount: Configs::ConfigServices.behavioral_learning_price
      }
    end

    def comprehensive_assessment_config
      {
        category: 'comprehensive_assessment_certificate',
        name: 'Comprehensive Assessment',
        default_amount: Configs::ConfigServices.comprehensive_assessment_price
      }
    end

    def tpa_config
      {
        category: 'tpa_certificate',
        name: 'TPA Assessment',
        default_amount: Configs::ConfigServices.tpa_price
      }
    end

    def default_test_config
      {
        category: 'general_certificate',
        name: 'Assessment',
        default_amount: Configs::ConfigServices.get('general_price', 50000)
      }
    end
  end
end
