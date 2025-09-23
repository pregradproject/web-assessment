ActiveAdmin.register ComprehensiveAssessmentTestAnswer do
  menu parent: 'Comprehensive Assessment'
  permit_params :comprehensive_assessment_test_id, :comprehensive_assessment_question_id, :comprehensive_assessment_category_id, :point, :answered_at

  index do
    selectable_column
    id_column
    column 'Test' do |answer|
      link_to "Test ##{answer.comprehensive_assessment_test.id}", admin_comprehensive_assessment_test_path(answer.comprehensive_assessment_test) if answer.comprehensive_assessment_test.present?
    end
    column 'User' do |answer|
      answer.comprehensive_assessment_test.user.name if answer.comprehensive_assessment_test&.user.present?
    end
    column 'Question' do |answer|
      truncate(answer.comprehensive_assessment_question.body, length: 80) if answer.comprehensive_assessment_question.present?
    end
    column 'Category' do |answer|
      answer.comprehensive_assessment_category.name if answer.comprehensive_assessment_category.present?
    end
    column :point
    column :answered_at
    actions
  end

  filter :comprehensive_assessment_test, as: :select, collection: -> { ComprehensiveAssessmentTest.joins(:user).order('users.name') }
  filter :comprehensive_assessment_category, as: :select, collection: -> { ComprehensiveAssessmentCategory.order(:name) }
  filter :point, as: :select, collection: (1..5).to_a
  filter :answered_at

  form do |f|
    f.inputs 'Test Answer Details' do
      f.input :comprehensive_assessment_test, as: :select, collection: ComprehensiveAssessmentTest.includes(:user).order('users.name')
      f.input :comprehensive_assessment_question, as: :select, collection: ComprehensiveAssessmentQuestion.order(:body)
      f.input :comprehensive_assessment_category, as: :select, collection: ComprehensiveAssessmentCategory.order(:name)
      f.input :point, as: :select, collection: (1..5).to_a
      f.input :answered_at, as: :datepicker
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row 'Test' do |answer|
        link_to "Test ##{answer.comprehensive_assessment_test.id}", admin_comprehensive_assessment_test_path(answer.comprehensive_assessment_test) if answer.comprehensive_assessment_test.present?
      end
      row 'User' do |answer|
        link_to answer.comprehensive_assessment_test.user.name, admin_user_path(answer.comprehensive_assessment_test.user) if answer.comprehensive_assessment_test&.user.present?
      end
      row 'Question' do |answer|
        answer.comprehensive_assessment_question.body if answer.comprehensive_assessment_question.present?
      end
      row 'Category' do |answer|
        link_to answer.comprehensive_assessment_category.name, admin_comprehensive_assessment_category_path(answer.comprehensive_assessment_category) if answer.comprehensive_assessment_category.present?
      end
      row :point
      row :answered_at
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
