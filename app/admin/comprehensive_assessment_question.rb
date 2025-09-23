ActiveAdmin.register ComprehensiveAssessmentQuestion do
  menu parent: 'Comprehensive Assessment'
  permit_params :body, :comprehensive_assessment_category_id, :comprehensive_assessment_question_set_id

  index do
    selectable_column
    id_column
    column :body do |question|
      truncate(question.body, length: 100)
    end
    column :category do |question|
      question.comprehensive_assessment_category.name if question.comprehensive_assessment_category.present?
    end
    column :question_set do |question|
      question.comprehensive_assessment_question_set.name if question.comprehensive_assessment_question_set.present?
    end
    column :created_at
    actions
  end

  filter :comprehensive_assessment_category, as: :select, collection: -> { ComprehensiveAssessmentCategory.order(:name) }
  filter :comprehensive_assessment_question_set, as: :select, collection: -> { ComprehensiveAssessmentQuestionSet.order(:name) }
  filter :body

  form do |f|
    f.inputs 'Question Details' do
      f.input :comprehensive_assessment_question_set, as: :select, collection: ComprehensiveAssessmentQuestionSet.order(:name)
      f.input :comprehensive_assessment_category, as: :select, collection: ComprehensiveAssessmentCategory.order(:name)
      f.input :body, as: :text
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :body
      row :category do |question|
        link_to question.comprehensive_assessment_category.name, admin_comprehensive_assessment_category_path(question.comprehensive_assessment_category) if question.comprehensive_assessment_category.present?
      end
      row :question_set do |question|
        link_to question.comprehensive_assessment_question_set.name, admin_comprehensive_assessment_question_set_path(question.comprehensive_assessment_question_set) if question.comprehensive_assessment_question_set.present?
      end
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end
end
