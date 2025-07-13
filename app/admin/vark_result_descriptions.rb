ActiveAdmin.register VarkResultDescription do
  menu parent: 'Vark'
  permit_params :combination_pattern, :title, :description, :characteristics,
                :study_recommendations, :strengths, :potential_challenges,
                :career_suggestions, :active

  index do
    selectable_column
    id_column
    column :combination_pattern
    column :title
    column :style_type
    column :active
    column :created_at
    actions
  end

  filter :combination_pattern
  filter :title
  filter :active
  filter :created_at

  show do
    attributes_table do
      row :combination_pattern
      row :title
      row :style_type
      row :learning_styles do |description|
        description.learning_styles.join(', ')
      end
      row :multimodal do |description|
        description.multimodal? ? 'Yes' : 'No'
      end
      row :active
      row :created_at
      row :updated_at
    end

    panel 'Content' do
      attributes_table_for vark_result_description do
        row :description do |description|
          simple_format(description.description)
        end
        row :characteristics do |description|
          simple_format(description.characteristics)
        end
        row :study_recommendations do |description|
          simple_format(description.study_recommendations)
        end
        row :strengths do |description|
          simple_format(description.strengths)
        end
        row :potential_challenges do |description|
          simple_format(description.potential_challenges)
        end
        row :career_suggestions do |description|
          simple_format(description.career_suggestions)
        end
      end
    end
  end

  form do |f|
    f.inputs 'Basic Information' do
      f.input :combination_pattern, hint: 'Enter learning style codes (e.g., V, AV, ARK, ARKV). Will be automatically normalized.'
      f.input :title, hint: 'Display title for this learning style combination'
      f.input :active, hint: 'Whether this description is active and can be used'
    end

    f.inputs 'Content' do
      f.input :description, as: :text, input_html: { rows: 4 },
              hint: 'Main description of this learning style combination'
      f.input :characteristics, as: :text, input_html: { rows: 3 },
              hint: 'Key characteristics and preferences'
      f.input :study_recommendations, as: :text, input_html: { rows: 3 },
              hint: 'Effective study strategies and methods'
      f.input :strengths, as: :text, input_html: { rows: 3 },
              hint: 'Learning strengths and advantages'
      f.input :potential_challenges, as: :text, input_html: { rows: 3 },
              hint: 'Areas that may need attention'
      f.input :career_suggestions, as: :text, input_html: { rows: 3 },
              hint: 'Career fields that align with this learning style'
    end
    f.actions
  end

  # Custom actions
  member_action :preview, method: :get do
    @vark_result_description = resource
    render 'admin/vark_result_descriptions/preview'
  end

  action_item :preview, only: :show do
    link_to 'Preview', preview_admin_vark_result_description_path(vark_result_description)
  end

  # Batch actions
  batch_action :activate do |ids|
    batch_action_collection.find(ids).each do |description|
      description.update!(active: true)
    end
    redirect_to collection_path, alert: "#{ids.count} descriptions have been activated."
  end

  batch_action :deactivate do |ids|
    batch_action_collection.find(ids).each do |description|
      description.update!(active: false)
    end
    redirect_to collection_path, alert: "#{ids.count} descriptions have been deactivated."
  end

  # Scopes
  scope :all, default: true
  scope :active
  scope('Single Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 1') }
  scope('Dual Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 2') }
  scope('Triple Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 3') }
  scope('Balanced Multimodal') { |scope| scope.where('LENGTH(combination_pattern) = 4') }

  # Configuration
  config.per_page = 20
  config.sort_order = 'combination_pattern_asc'
end
