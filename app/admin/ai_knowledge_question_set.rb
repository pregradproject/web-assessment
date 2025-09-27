ActiveAdmin.register AiKnowledgeQuestionSet do
  menu parent: 'AI Knowledge', priority: 2
  permit_params :version, :name, :active, :time_limit

  config.clear_action_items!

  collection_action :import_from_google_sheets, method: :get do
    render 'admin/import_ai_knowledge_google_sheets'
  end

  collection_action :process_google_sheets_import, method: :post do
    begin
      service = AiKnowledgeGoogleSheetsImportService.new(params[:google_sheets_url], params[:time_limit])
      question_set = service.import!

      redirect_to admin_ai_knowledge_question_set_path(question_set),
                  notice: "Successfully imported #{question_set.ai_knowledge_questions.count} questions from Google Sheets!"
    rescue => e
      redirect_to import_from_google_sheets_admin_ai_knowledge_question_sets_path,
                  alert: "Import failed: #{e.message}"
    end
  end

  member_action :make_active, method: :patch do
    AiKnowledgeQuestionSet.where(active: true).update_all(active: false)
    resource.update!(active: true)
    redirect_to admin_ai_knowledge_question_sets_path, notice: 'Question set is now active!'
  end

  # Add import button to index page
  action_item :import_google_sheets, only: :index do
    link_to 'Import from Google Sheets',
            import_from_google_sheets_admin_ai_knowledge_question_sets_path,
            class: 'button'
  end

  index do
    selectable_column
    id_column
    column :version
    column :name
    column :active do |question_set|
      status_tag question_set.active? ? 'Yes' : 'No', class: question_set.active? ? 'ok' : 'error'
    end
    column :questions_count do |question_set|
      question_set.ai_knowledge_questions.count
    end
    column :time_limit do |question_set|
      if question_set.time_limit.present?
        question_set.time_limit
      else
        '-'
      end
    end
    column 'Tests Count' do |question_set|
      question_set.ai_knowledge_tests.count
    end
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_ai_knowledge_question_set_path(resource), class: 'member_link'
      unless resource.active?
        item 'Make Active', make_active_admin_ai_knowledge_question_set_path(resource), method: :patch, class: 'member_link'
      end
    end
  end

  filter :version
  filter :name
  filter :active
  filter :created_at

  show do
    attributes_table do
      row :id
      row :version
      row :name
      row :active do |question_set|
        status_tag question_set.active? ? 'Yes' : 'No', class: question_set.active? ? 'ok' : 'error'
      end
      row :time_limit do |question_set|
        if question_set.time_limit.present?
          "#{question_set.time_limit} minutes"
        else
          'No limit'
        end
      end
      row 'Total Questions' do |question_set|
        question_set.ai_knowledge_questions.count
      end
      row 'Tests Count' do |question_set|
        question_set.ai_knowledge_tests.count
      end
      row :created_at
      row :updated_at
    end

    panel 'Categories' do
      table_for resource.ai_knowledge_question_set_categories.includes(:ai_knowledge_category) do
        column 'Category' do |qsc|
          qsc.ai_knowledge_category.name
        end
        column 'Code' do |qsc|
          qsc.ai_knowledge_category.code
        end
        column 'Questions Count' do |qsc|
          qsc.ai_knowledge_category.ai_knowledge_questions.where(ai_knowledge_question_set: resource).count
        end
      end
    end

    panel 'Questions by Category' do
      resource.ai_knowledge_categories.each do |category|
        questions = resource.ai_knowledge_questions.where(ai_knowledge_category: category)
        next if questions.empty?

        h3 "#{category.name} (#{category.code}) - #{questions.count} questions"
        table_for questions do
          column :body do |question|
            truncate(question.body, length: 150)
          end
          column :created_at
        end
      end
    end

    panel 'Recent Tests' do
      recent_tests = resource.ai_knowledge_tests.includes(:user).order(created_at: :desc).limit(10)
      table_for recent_tests do
        column 'User' do |test|
          link_to test.user.name, admin_user_path(test.user) if test.user.present?
        end
        column :status do |test|
          status_tag test.status
        end
        column :started_at
        column :completed_at
        column 'Actions' do |test|
          link_to 'View', admin_ai_knowledge_test_path(test), class: 'view_link'
        end
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs 'Question Set Details' do
      f.input :version
      f.input :name
      f.input :time_limit, hint: 'Time limit (leave blank for no limit)'
      f.input :active
    end
    f.actions
  end

  # Add action to make question set active if it's not already active
  action_item :make_active, only: :show, if: proc { !resource.active? } do
    link_to 'Make Active', make_active_admin_ai_knowledge_question_set_path(resource), method: :patch,
            confirm: 'This will deactivate all other question sets and make this one active. Are you sure?'
  end
end
