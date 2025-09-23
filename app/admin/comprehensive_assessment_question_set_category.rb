ActiveAdmin.register ComprehensiveAssessmentQuestionSetCategory do
  menu parent: 'Comprehensive Assessment'
  permit_params :comprehensive_assessment_question_set_id, :comprehensive_assessment_category_id

  index do
    selectable_column
    id_column
    column :question_set do |qsc|
      qsc.comprehensive_assessment_question_set.name if qsc.comprehensive_assessment_question_set.present?
    end
    column :category do |qsc|
      qsc.comprehensive_assessment_category.name if qsc.comprehensive_assessment_category.present?
    end
    column :created_at
    actions
  end

  filter :comprehensive_assessment_question_set, as: :select, collection: -> { ComprehensiveAssessmentQuestionSet.order(:name) }
  filter :comprehensive_assessment_category, as: :select, collection: -> { ComprehensiveAssessmentCategory.order(:name) }

  form do |f|
    f.inputs 'Question Set Category Details' do
      f.input :comprehensive_assessment_question_set, as: :select, collection: ComprehensiveAssessmentQuestionSet.order(:name)
      f.input :comprehensive_assessment_category, as: :select, collection: ComprehensiveAssessmentCategory.order(:name)
    end
    f.actions
  end
end
