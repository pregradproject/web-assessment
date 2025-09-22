# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Platform Overview' do
          attributes_table do
            row 'Total Users' do
              User.count
            end
            row 'Total Orders' do
              Order.count
            end
            row 'Total Revenue' do
              number_to_currency(Order.paid.sum(:amount))
            end
            row 'Active Admin Users' do
              AdminUser.count
            end
          end
        end

        panel 'VARK Assessment Stats' do
          attributes_table do
            row 'Total VARK Tests' do
              VarkTest.count
            end
            row 'Completed VARK Tests' do
              VarkTest.completed.count
            end
            row 'In Progress VARK Tests' do
              VarkTest.in_progress.count
            end
            row 'Active Question Set' do
              vark_set = VarkQuestionSet.current_active
              link_to vark_set.name, admin_vark_question_set_path(vark_set) if vark_set
            end
          end
        end

        panel 'AI Knowledge Assessment Stats' do
          attributes_table do
            row 'Total AI Tests' do
              AiKnowledgeTest.count
            end
            row 'Completed AI Tests' do
              AiKnowledgeTest.completed.count
            end
            row 'In Progress AI Tests' do
              AiKnowledgeTest.in_progress.count
            end
            row 'Active Question Set' do
              ai_set = AiKnowledgeQuestionSet.current_active
              link_to ai_set.name, admin_ai_knowledge_question_set_path(ai_set) if ai_set
            end
          end
        end

        panel 'Behavioral Learning Assessment Stats' do
          attributes_table do
            row 'Total Behavioral Tests' do
              BehavioralLearningTest.count
            end
            row 'Completed Behavioral Tests' do
              BehavioralLearningTest.completed.count
            end
            row 'In Progress Behavioral Tests' do
              BehavioralLearningTest.in_progress.count
            end
            row 'Active Question Set' do
              behavioral_set = BehavioralLearningQuestionSet.current_active
              link_to behavioral_set.name, admin_behavioral_learning_question_set_path(behavioral_set) if behavioral_set
            end
          end
        end
      end

      column do
        panel 'Recent Activity' do
          table_for Order.includes(:user, :orderable).recent.limit(10) do
            column 'Order #' do |order|
              link_to order.order_number, admin_order_path(order)
            end
            column 'User' do |order|
              link_to order.user.name, admin_user_path(order.user) if order.user
            end
            column 'Test Type' do |order|
              order.category.humanize
            end
            column 'Amount' do |order|
              number_to_currency(order.amount)
            end
            column 'Status' do |order|
              status_tag order.status
            end
            column 'Created' do |order|
              time_ago_in_words(order.created_at) + ' ago'
            end
          end
        end

        panel 'Recent Test Completions' do
          ul do
            VarkTest.completed.recent.limit(5).each do |test|
              li "#{link_to(test.user.name, admin_user_path(test.user))} completed VARK test - #{time_ago_in_words(test.completed_at)} ago".html_safe
            end
            AiKnowledgeTest.completed.recent.limit(5).each do |test|
              li "#{link_to(test.user.name, admin_user_path(test.user))} completed AI Knowledge test - #{time_ago_in_words(test.completed_at)} ago".html_safe
            end
            BehavioralLearningTest.completed.recent.limit(5).each do |test|
              li "#{link_to(test.user.name, admin_user_path(test.user))} completed Behavioral Learning test - #{time_ago_in_words(test.completed_at)} ago".html_safe
            end
          end
        end

        panel 'System Configuration' do
          attributes_table do
            row 'VARK Test Price' do
              number_to_currency(Configs::ConfigServices.vark_price)
            end
            row 'AI Knowledge Test Price' do
              number_to_currency(Configs::ConfigServices.ai_knowledge_price)
            end
            row 'Behavioral Learning Test Price' do
              number_to_currency(Configs::ConfigServices.behavioral_learning_price)
            end
            row 'Environment' do
              Rails.env.titleize
            end
            row 'Rails Version' do
              Rails.version
            end
          end
        end
      end
    end
  end # content
end
