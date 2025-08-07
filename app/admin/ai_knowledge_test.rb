ActiveAdmin.register AiKnowledgeTest do
  menu parent: 'AI Knowledge', priority: 1

  actions :index, :show

  permit_params :user_id, :ai_knowledge_question_set_id, :started_at, :completed_at, :status

  # Filters
  filter :user, as: :select, collection: -> { User.order(:name) }
  filter :ai_knowledge_question_set, as: :select, collection: -> { AiKnowledgeQuestionSet.order(:name) }
  filter :status, as: :select, collection: AiKnowledgeTest.statuses
  filter :started_at
  filter :completed_at
  filter :created_at
  filter :updated_at

  # Scopes
  scope :all
  scope :in_progress
  scope :completed
  scope :expired

  # Index page
  index do
    selectable_column
    id_column
    column 'User' do |test|
      link_to test.user.name, admin_user_path(test.user) if test.user.present?
    end
    column 'Question Set' do |test|
      link_to test.ai_knowledge_question_set.name, admin_ai_knowledge_question_set_path(test.ai_knowledge_question_set) if test.ai_knowledge_question_set.present?
    end
    column :status do |test|
      status_tag test.status
    end
    column :started_at
    column :completed_at
    column 'Duration' do |test|
      if test.completed_at.present? && test.started_at.present?
        distance_of_time_in_words(test.started_at, test.completed_at)
      elsif test.started_at.present?
        distance_of_time_in_words(test.started_at, Time.current)
      else
        '-'
      end
    end
    column 'Time Remaining' do |test|
      if test.status == 'in_progress'
        remaining = test.time_remaining
        if remaining > 0
          "#{remaining} minutes"
        else
          status_tag 'Expired', class: 'error'
        end
      else
        '-'
      end
    end
    column 'Answers Count' do |test|
      test.ai_knowledge_test_answers.count
    end
    column 'Has Result' do |test|
      test.ai_knowledge_result_level.present? ? status_tag('Yes', class: 'ok') : status_tag('No', class: 'error')
    end
    column 'Has Order' do |test|
      test.order.present? ? status_tag('Yes', class: 'ok') : status_tag('No', class: 'error')
    end
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_ai_knowledge_test_path(resource), class: 'view_link'
    end
  end

  # Show page
  show do
    attributes_table do
      row :id
      row 'User' do |test|
        link_to test.user.name, admin_user_path(test.user) if test.user.present?
      end
      row 'Question Set' do |test|
        link_to test.ai_knowledge_question_set.name, admin_ai_knowledge_question_set_path(test.ai_knowledge_question_set) if test.ai_knowledge_question_set.present?
      end
      row :status do |test|
        status_tag test.status
      end
      row :started_at
      row :completed_at
      row 'Duration' do |test|
        if test.completed_at.present? && test.started_at.present?
          distance_of_time_in_words(test.started_at, test.completed_at)
        elsif test.started_at.present?
          distance_of_time_in_words(test.started_at, Time.current)
        else
          '-'
        end
      end
      row 'Time Remaining' do |test|
        if test.status == 'in_progress'
          remaining = test.time_remaining
          if remaining > 0
            "#{remaining} minutes"
          else
            status_tag 'Expired', class: 'error'
          end
        else
          '-'
        end
      end
      row 'Answers Count' do |test|
        test.ai_knowledge_test_answers.count
      end
      row 'Questions Count' do |test|
        test.ai_knowledge_question_set.ai_knowledge_questions.count if test.ai_knowledge_question_set.present?
      end
      row 'Completion Percentage' do |test|
        if test.ai_knowledge_question_set.present?
          total_questions = test.ai_knowledge_question_set.ai_knowledge_questions.count
          answered_questions = test.ai_knowledge_test_answers.count
          if total_questions > 0
            percentage = (answered_questions.to_f / total_questions * 100).round(2)
            "#{percentage}% (#{answered_questions}/#{total_questions})"
          else
            '0%'
          end
        else
          '-'
        end
      end
      row 'Has Result' do |test|
        test.ai_knowledge_result_level.present? ? status_tag('Yes', class: 'ok') : status_tag('No', class: 'error')
      end
      row 'Has Order' do |test|
        if test.order.present?
          link_to "Order ##{test.order.order_number}", admin_order_path(test.order)
        else
          status_tag('No', class: 'error')
        end
      end
      row :created_at
      row :updated_at
    end

    # Test Results section
    if resource.ai_knowledge_result_level.present?
      panel 'Test Results' do
        attributes_table_for resource.ai_knowledge_result_level do
          row :performance_expectancy_score
          row :effort_expectancy_score
          row :social_influence_score
          row :facilitating_conditions_score
          row :hedonic_motivation_score
          row :price_value_score
          row :habit_score
          row :behavioral_intention_score
          row 'Total Score' do |result|
            result.total_score
          end
          row 'Dominant Learning Styles' do |result|
            result.dominant_learning_styles.join(', ')
          end
          row :created_at
        end
      end
    end

    # Test Answers section
    if resource.ai_knowledge_test_answers.any?
      panel 'Test Answers' do
        table_for resource.ai_knowledge_test_answers.includes(:ai_knowledge_question) do
          column 'Question' do |answer|
            truncate(answer.ai_knowledge_question.body, length: 100) if answer.ai_knowledge_question.present?
          end
          column 'Category' do |answer|
            answer.ai_knowledge_question.ai_knowledge_category.name if answer.ai_knowledge_question&.ai_knowledge_category.present?
          end
          column :point
          column :created_at
        end
      end
    end

    # Order Information section
    if resource.order.present?
      panel 'Order Information' do
        attributes_table_for resource.order do
          row :order_number
          row :amount
          row :status do |order|
            status_tag order.status
          end
          row :category
          row :certificate_status do |order|
            status_tag order.certificate_status
          end
          row :expires_at
          row :created_at
        end
      end
    end

    active_admin_comments
  end

  # Form
  form do |f|
    f.inputs 'Test Details' do
      f.input :user, as: :select, collection: User.order(:name)
      f.input :ai_knowledge_question_set, as: :select, collection: AiKnowledgeQuestionSet.order(:name)
      f.input :status, as: :select, collection: AiKnowledgeTest.statuses
      f.input :started_at, as: :datepicker
      f.input :completed_at, as: :datepicker
    end
    f.actions
  end

  # Custom actions
  member_action :force_complete, method: :patch do
    if resource.in_progress?
      resource.update!(status: 'completed', completed_at: Time.current)
      redirect_to admin_ai_knowledge_test_path(resource), notice: 'Test marked as completed.'
    else
      redirect_to admin_ai_knowledge_test_path(resource), alert: 'Test is not in progress.'
    end
  end

  member_action :extend_time, method: :patch do
    if resource.in_progress?
      # Extend by 30 minutes
      resource.update!(started_at: resource.started_at - 30.minutes)
      redirect_to admin_ai_knowledge_test_path(resource), notice: 'Test time extended by 30 minutes.'
    else
      redirect_to admin_ai_knowledge_test_path(resource), alert: 'Test is not in progress.'
    end
  end

  action_item :force_complete, only: :show, if: proc { resource.in_progress? } do
    link_to 'Force Complete', force_complete_admin_ai_knowledge_test_path(resource), method: :patch,
            confirm: 'Are you sure you want to mark this test as completed?'
  end

  action_item :extend_time, only: :show, if: proc { resource.in_progress? } do
    link_to 'Extend Time (+30 min)', extend_time_admin_ai_knowledge_test_path(resource), method: :patch,
            confirm: 'Are you sure you want to extend the test time by 30 minutes?'
  end

  # CSV export
  csv do
    column :id
    column('User') { |test| test.user.name }
    column('User Email') { |test| test.user.email }
    column('Question Set') { |test| test.ai_knowledge_question_set.name }
    column :status
    column :started_at
    column :completed_at
    column('Duration (minutes)') do |test|
      if test.completed_at.present? && test.started_at.present?
        ((test.completed_at - test.started_at) / 60).round(2)
      else
        nil
      end
    end
    column('Answers Count') { |test| test.ai_knowledge_test_answers.count }
    column('Has Result') { |test| test.ai_knowledge_result_level.present? }
    column('Has Order') { |test| test.order.present? }
    column :created_at
    column :updated_at
  end
end
