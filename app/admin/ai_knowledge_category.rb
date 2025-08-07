ActiveAdmin.register AiKnowledgeCategory do
  menu parent: 'AI Knowledge'
  permit_params :code, :name, :description, :result_text

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :description
    column :result_text
    column 'Questions Count' do |category|
      category.ai_knowledge_questions.count
    end
    column :created_at
    actions
  end

  filter :code
  filter :name

  show do
    attributes_table do
      row :id
      row :code
      row :name
      row :description
      row :result_text
      row :created_at
      row :updated_at
    end

    panel 'Questions' do
      table_for resource.ai_knowledge_questions.includes(:ai_knowledge_question_set) do
        column 'Question Set' do |question|
          link_to question.ai_knowledge_question_set.name, admin_ai_knowledge_question_set_path(question.ai_knowledge_question_set) if question.ai_knowledge_question_set.present?
        end
        column :body do |question|
          truncate(question.body, length: 100)
        end
        column :created_at
      end
    end

    panel 'Tests Using This Category' do
      category_tests = AiKnowledgeTest.joins(ai_knowledge_question_set: :ai_knowledge_categories)
                                     .where(ai_knowledge_categories: { id: resource.id })
                                     .distinct
                                     .limit(10)
                                     .includes(:user, :ai_knowledge_question_set)

      table_for category_tests do
        column 'User' do |test|
          link_to test.user.name, admin_user_path(test.user) if test.user.present?
        end
        column 'Question Set' do |test|
          link_to test.ai_knowledge_question_set.name, admin_ai_knowledge_question_set_path(test.ai_knowledge_question_set) if test.ai_knowledge_question_set.present?
        end
        column :status do |test|
          status_tag test.status
        end
        column :created_at
        column 'Actions' do |test|
          link_to 'View', admin_ai_knowledge_test_path(test), class: 'view_link'
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'AI Knowledge Category Details' do
      f.input :code, hint: 'Use standard codes: PE, EE, SI, FC, HM, PV, HT, BI'
      f.input :name
      f.input :description
      f.input :result_text
    end
    f.actions
  end
end
