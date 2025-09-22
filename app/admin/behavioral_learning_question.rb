ActiveAdmin.register BehavioralLearningQuestion do
  menu parent: 'Behavioral Learning'
  permit_params :body, :behavioral_learning_category_id, :behavioral_learning_question_set_id

  index do
    selectable_column
    id_column
    column :body do |question|
      truncate(question.body, length: 100)
    end
    column :category do |question|
      question.behavioral_learning_category.name if question.behavioral_learning_category.present?
    end
    column :question_set do |question|
      question.behavioral_learning_question_set.name if question.behavioral_learning_question_set.present?
    end
    column :created_at
    actions
  end

  filter :behavioral_learning_category, as: :select, collection: -> { BehavioralLearningCategory.order(:name) }
  filter :behavioral_learning_question_set, as: :select, collection: -> { BehavioralLearningQuestionSet.order(:name) }
  filter :body

  form do |f|
    f.inputs 'Question Details' do
      f.input :behavioral_learning_question_set, as: :select, collection: BehavioralLearningQuestionSet.order(:name)
      f.input :behavioral_learning_category, as: :select, collection: BehavioralLearningCategory.order(:name)
      f.input :body, as: :text
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :body
      row :category do |question|
        link_to question.behavioral_learning_category.name, admin_behavioral_learning_category_path(question.behavioral_learning_category) if question.behavioral_learning_category.present?
      end
      row :question_set do |question|
        link_to question.behavioral_learning_question_set.name, admin_behavioral_learning_question_set_path(question.behavioral_learning_question_set) if question.behavioral_learning_question_set.present?
      end
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
