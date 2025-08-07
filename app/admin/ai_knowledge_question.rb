ActiveAdmin.register AiKnowledgeQuestion do
  menu parent: 'AI Knowledge'
  permit_params :ai_knowledge_question_set_id, :ai_knowledge_category_id, :body, :max_weight

  index do
    selectable_column
    id_column
    column 'Question Set' do |question|
      link_to question.ai_knowledge_question_set.name, admin_ai_knowledge_question_set_path(question.ai_knowledge_question_set) if question.ai_knowledge_question_set.present?
    end
    column 'Category' do |question|
      question.ai_knowledge_category.name if question.ai_knowledge_category.present?
    end
    column :body do |question|
      truncate(question.body, length: 100)
    end
    column :max_weight
    column 'Answers Count' do |question|
      question.ai_knowledge_test_answers.count
    end
    column :created_at
    actions
  end

  filter :ai_knowledge_question_set, as: :select, collection: -> { AiKnowledgeQuestionSet.order(:name) }
  filter :ai_knowledge_category, as: :select, collection: -> { AiKnowledgeCategory.order(:name) }
  filter :body
  filter :max_weight
  filter :created_at

  show do
    attributes_table do
      row :id
      row 'Question Set' do |question|
        link_to question.ai_knowledge_question_set.name, admin_ai_knowledge_question_set_path(question.ai_knowledge_question_set) if question.ai_knowledge_question_set.present?
      end
      row 'Category' do |question|
        question.ai_knowledge_category.name if question.ai_knowledge_category.present?
      end
      row :body
      row :max_weight
      row 'Answers Count' do |question|
        question.ai_knowledge_test_answers.count
      end
      row :created_at
      row :updated_at
    end

    panel 'Recent Answers' do
      recent_answers = resource.ai_knowledge_test_answers.includes(ai_knowledge_test: :user).order(created_at: :desc).limit(10)
      table_for recent_answers do
        column 'User' do |answer|
          link_to answer.ai_knowledge_test.user.name, admin_user_path(answer.ai_knowledge_test.user) if answer.ai_knowledge_test&.user.present?
        end
        column 'Test' do |answer|
          link_to "Test ##{answer.ai_knowledge_test.id}", admin_ai_knowledge_test_path(answer.ai_knowledge_test) if answer.ai_knowledge_test.present?
        end
        column :point
        column :answered_at
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'Question Details' do
      f.input :ai_knowledge_question_set, as: :select, collection: AiKnowledgeQuestionSet.order(:name)
      f.input :ai_knowledge_category, as: :select, collection: AiKnowledgeCategory.order(:name)
      f.input :body, as: :text, rows: 5
      f.input :max_weight, hint: 'Maximum weight for this question (default: 5)'
    end
    f.actions
  end

  scope :all
  scope 'Performance Expectancy', :performance_expectancy do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'PE' })
  end
  scope 'Effort Expectancy', :effort_expectancy do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'EE' })
  end
  scope 'Social Influence', :social_influence do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'SI' })
  end
  scope 'Facilitating Conditions', :facilitating_conditions do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'FC' })
  end
  scope 'Hedonic Motivation', :hedonic_motivation do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'HM' })
  end
  scope 'Price Value', :price_value do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'PV' })
  end
  scope 'Habit', :habit do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'HT' })
  end
  scope 'Behavioral Intention', :behavioral_intention do |questions|
    questions.joins(:ai_knowledge_category).where(ai_knowledge_categories: { code: 'BI' })
  end
end
