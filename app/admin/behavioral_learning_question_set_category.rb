ActiveAdmin.register BehavioralLearningQuestionSetCategory do
  menu parent: 'Behavioral Learning'
  permit_params :behavioral_learning_question_set_id, :behavioral_learning_category_id

  index do
    selectable_column
    id_column
    column :question_set do |qsc|
      qsc.behavioral_learning_question_set.name if qsc.behavioral_learning_question_set.present?
    end
    column :category do |qsc|
      qsc.behavioral_learning_category.name if qsc.behavioral_learning_category.present?
    end
    column :created_at
    actions
  end

  filter :behavioral_learning_question_set, as: :select, collection: -> { BehavioralLearningQuestionSet.order(:name) }
  filter :behavioral_learning_category, as: :select, collection: -> { BehavioralLearningCategory.order(:name) }

  form do |f|
    f.inputs 'Question Set Category Details' do
      f.input :behavioral_learning_question_set, as: :select, collection: BehavioralLearningQuestionSet.order(:name)
      f.input :behavioral_learning_category, as: :select, collection: BehavioralLearningCategory.order(:name)
    end
    f.actions
  end
end
