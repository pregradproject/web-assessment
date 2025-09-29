ActiveAdmin.register ComprehensiveAssessmentThresholdLevel do
  menu parent: 'Comprehensive Assessment'
  permit_params :level_label, :level_message, :threshold_min, :threshold_max

  index do
    selectable_column
    id_column
    column :level_label
    column :threshold_min
    column :threshold_max
    column :level_message do |threshold|
      truncate(threshold.level_message, length: 100)
    end
    column :created_at
    actions
  end

  filter :level_label
  filter :threshold_min
  filter :threshold_max

  form do |f|
    f.inputs 'Threshold Level Details' do
      f.input :level_label
      f.input :level_message, as: :text
      f.input :threshold_min
      f.input :threshold_max
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :level_label
      row :level_message
      row :threshold_min
      row :threshold_max
      row 'Score Range' do |threshold|
        "#{threshold.threshold_min} - #{threshold.threshold_max}"
      end
      row :created_at
      row :updated_at
    end

    panel 'Related Results' do
      table_for ComprehensiveAssessmentResultLevel.where(level_label: resource.label).includes(:user, :comprehensive_assessment_test) do
        column 'User' do |result|
          link_to result.user.name, admin_user_path(result.user) if result.user.present?
        end
        column 'Test' do |result|
          link_to "Test ##{result.comprehensive_assessment_test.id}", admin_comprehensive_assessment_test_path(result.comprehensive_assessment_test) if result.comprehensive_assessment_test.present?
        end
        column :average_score
        column :created_at
      end
    end

    active_admin_comments
  end
end
