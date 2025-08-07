ActiveAdmin.register AiKnowledgeResultDescription do
  menu parent: 'AI Knowledge'
  permit_params :combination_pattern, :title, :description, :characteristics,
                :study_recommendations, :strengths, :potential_challenges,
                :career_suggestions, :active

  index do
    selectable_column
    id_column
    column :combination_pattern
    column :title do |description|
      truncate(description.title, length: 50)
    end
    column :style_type
    column :active do |description|
      status_tag description.active? ? 'Yes' : 'No', class: description.active? ? 'ok' : 'error'
    end
    column 'Components Count' do |description|
      description.combination_pattern.length / 2
    end
    column :created_at
    actions
  end

  filter :combination_pattern
  filter :title
  filter :active
  filter :created_at

  show do
    attributes_table do
      row :id
      row :combination_pattern
      row :title
      row :style_type
      row :learning_styles do |description|
        description.learning_styles.join(', ')
      end
      row :multimodal do |description|
        description.multimodal? ? 'Yes' : 'No'
      end
      row 'Components Count' do |description|
        description.combination_pattern.length / 2
      end
      row :active do |description|
        status_tag description.active? ? 'Yes' : 'No', class: description.active? ? 'ok' : 'error'
      end
      row :created_at
      row :updated_at
    end

    panel 'Content' do
      attributes_table_for ai_knowledge_result_description do
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

    panel 'Usage Statistics' do
      # Find tests that might use this description
      matching_tests = AiKnowledgeTest.joins(:ai_knowledge_result_level)
                                     .where.not(ai_knowledge_result_levels: { id: nil })
                                     .limit(5)

      if matching_tests.any?
        table_for matching_tests.includes(:user) do
          column 'User' do |test|
            link_to test.user.name, admin_user_path(test.user) if test.user.present?
          end
          column :status do |test|
            status_tag test.status
          end
          column :completed_at
          column 'Actions' do |test|
            link_to 'View', admin_ai_knowledge_test_path(test), class: 'view_link'
          end
        end
      else
        para 'No tests found that might use this description pattern.'
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'Basic Information' do
      f.input :combination_pattern, hint: 'Enter AI Knowledge codes (e.g., PE, EEPE, PEHM, etc.). Use standard codes: PE, EE, SI, FC, HM, PV, HT, BI. Will be automatically normalized and sorted.'
      f.input :title, hint: 'Display title for this AI knowledge combination'
      f.input :active, hint: 'Whether this description is active and can be used'
    end

    f.inputs 'Content' do
      f.input :description, as: :text, input_html: { rows: 4 },
              hint: 'Main description of this AI knowledge combination'
      f.input :characteristics, as: :text, input_html: { rows: 3 },
              hint: 'Key characteristics and technology acceptance preferences'
      f.input :study_recommendations, as: :text, input_html: { rows: 3 },
              hint: 'Effective learning strategies and technology adoption methods'
      f.input :strengths, as: :text, input_html: { rows: 3 },
              hint: 'Learning strengths and technology adoption advantages'
      f.input :potential_challenges, as: :text, input_html: { rows: 3 },
              hint: 'Areas that may need attention in technology adoption'
      f.input :career_suggestions, as: :text, input_html: { rows: 3 },
              hint: 'Career fields and technology roles that align with this profile'
    end
    f.actions
  end

  # Custom actions
  member_action :preview, method: :get do
    @ai_knowledge_result_description = resource
    render plain: "Preview functionality would show formatted content for: #{resource.title}"
  end

  action_item :preview, only: :show do
    link_to 'Preview', preview_admin_ai_knowledge_result_description_path(ai_knowledge_result_description)
  end

  # Batch actions
  batch_action :activate do |ids|
    batch_action_collection.find(ids).each do |description|
      description.update!(active: true)
    end
    redirect_to collection_path, notice: "#{ids.count} descriptions have been activated."
  end

  batch_action :deactivate do |ids|
    batch_action_collection.find(ids).each do |description|
      description.update!(active: false)
    end
    redirect_to collection_path, notice: "#{ids.count} descriptions have been deactivated."
  end

  # Scopes
  scope :all, default: true
  scope :active
  scope('Single Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 2') }
  scope('Dual Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 4') }
  scope('Triple Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 6') }
  scope('Quadruple Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 8') }
  scope('Quintuple Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 10') }
  scope('Sextuple Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 12') }
  scope('Septuple Dominant') { |scope| scope.where('LENGTH(combination_pattern) = 14') }
  scope('Balanced Multimodal') { |scope| scope.where('LENGTH(combination_pattern) = 16') }

  # Configuration
  config.per_page = 25
  config.sort_order = 'combination_pattern_asc'

  # Collection action to check coverage
  collection_action :check_coverage, method: :get do
    @total_possible = 255
    @total_created = AiKnowledgeResultDescription.count
    @active_count = AiKnowledgeResultDescription.active.count
    @missing_patterns = []

    # This would be computationally expensive to check all 255 combinations in real-time
    # Better to implement as a background job or rake task
    render plain: "Coverage Check: #{@total_created}/#{@total_possible} patterns created, #{@active_count} active"
  end

  action_item :check_coverage, only: :index do
    link_to 'Check Coverage', check_coverage_admin_ai_knowledge_result_descriptions_path
  end
end
