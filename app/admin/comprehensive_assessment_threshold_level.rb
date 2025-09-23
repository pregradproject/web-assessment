ActiveAdmin.register ComprehensiveAssessmentThresholdLevel do
  menu parent: 'Comprehensive Assessment'
  permit_params :label, :message, :min_threshold, :max_threshold, :priority

  index do
    selectable_column
    id_column
    column :label
    column :min_threshold
    column :max_threshold
    column :priority
    column :message do |threshold|
      truncate(threshold.message, length: 100)
    end
    column :created_at
    actions
  end

  filter :label
  filter :min_threshold
  filter :max_threshold
  filter :priority

  form do |f|
    f.inputs 'Threshold Level Details' do
      f.input :label
      f.input :message, as: :text
      f.input :min_threshold, step: 0.01
      f.input :max_threshold, step: 0.01
      f.input :priority, hint: 'Higher priority levels are selected first when scores match multiple thresholds'
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :label
      row :message
      row :min_threshold
      row :max_threshold
      row :priority
      row 'Score Range' do |threshold|
        "#{threshold.min_threshold} - #{threshold.max_threshold}"
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
