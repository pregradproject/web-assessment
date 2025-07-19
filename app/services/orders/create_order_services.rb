module Orders
  class CreateOrderServices < ApplicationService
    def initialize(test, amount = nil)
      @test = test
      @amount = amount
    end

    def call
      ActiveRecord::Base.transaction do
        create_order
      end

      @order
    end

    private

    def create_order
      test_config = get_test_config(@test)
      amount = @amount || test_config[:default_amount]

      @order = @test.create_order(
        user: @test.user,
        amount: amount,
        category: test_config[:category],
        description: "#{test_config[:name]} Certificate for #{@test.user.name}"
      )
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
