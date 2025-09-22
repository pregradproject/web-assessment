ActiveAdmin.register BehavioralLearningTestAnswer do
  menu parent: 'Behavioral Learning'
  permit_params :behavioral_learning_test_id, :behavioral_learning_question_id, :behavioral_learning_category_id, :point, :answered_at

  index do
    selectable_column
    id_column
    column 'Test' do |answer|
      link_to "Test ##{answer.behavioral_learning_test.id}", admin_behavioral_learning_test_path(answer.behavioral_learning_test) if answer.behavioral_learning_test.present?
    end
    column 'User' do |answer|
      answer.behavioral_learning_test.user.name if answer.behavioral_learning_test&.user.present?
    end
    column 'Question' do |answer|
      truncate(answer.behavioral_learning_question.body, length: 80) if answer.behavioral_learning_question.present?
    end
    column 'Category' do |answer|
      answer.behavioral_learning_category.name if answer.behavioral_learning_category.present?
    end
    column :point
    column :answered_at
    actions
  end

  filter :behavioral_learning_test, as: :select, collection: -> { BehavioralLearningTest.joins(:user).order('users.name') }
  filter :behavioral_learning_category, as: :select, collection: -> { BehavioralLearningCategory.order(:name) }
  filter :point, as: :select, collection: (1..5).to_a
  filter :answered_at

  form do |f|
    f.inputs 'Test Answer Details' do
      f.input :behavioral_learning_test, as: :select, collection: BehavioralLearningTest.includes(:user).order('users.name')
      f.input :behavioral_learning_question, as: :select, collection: BehavioralLearningQuestion.order(:body)
      f.input :behavioral_learning_category, as: :select, collection: BehavioralLearningCategory.order(:name)
      f.input :point, as: :select, collection: (1..5).to_a
      f.input :answered_at, as: :datepicker
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row 'Test' do |answer|
        link_to "Test ##{answer.behavioral_learning_test.id}", admin_behavioral_learning_test_path(answer.behavioral_learning_test) if answer.behavioral_learning_test.present?
      end
      row 'User' do |answer|
        link_to answer.behavioral_learning_test.user.name, admin_user_path(answer.behavioral_learning_test.user) if answer.behavioral_learning_test&.user.present?
      end
      row 'Question' do |answer|
        answer.behavioral_learning_question.body if answer.behavioral_learning_question.present?
      end
      row 'Category' do |answer|
        link_to answer.behavioral_learning_category.name, admin_behavioral_learning_category_path(answer.behavioral_learning_category) if answer.behavioral_learning_category.present?
      end
      row :point
      row :answered_at
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
