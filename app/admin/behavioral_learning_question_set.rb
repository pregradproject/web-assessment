ActiveAdmin.register BehavioralLearningQuestionSet do
  permit_params :version, :name, :active, :time_limit

  config.clear_action_items!

  collection_action :import_from_google_sheets, method: :get do
    render 'admin/import_google_sheets_behavioral_learning'
  end

  collection_action :process_google_sheets_import, method: :post do
    begin
      service = BehavioralLearningGoogleSheetsImportService.new(params[:google_sheets_url], params[:time_limit])
      question_set = service.import!

      redirect_to admin_behavioral_learning_question_set_path(question_set),
                  notice: "Successfully imported #{question_set.behavioral_learning_questions.count} questions from Google Sheets!"
    rescue => e
      redirect_to import_from_google_sheets_admin_behavioral_learning_question_sets_path,
                  alert: "Import failed: #{e.message}"
    end
  end

  member_action :make_active, method: :patch do
    BehavioralLearningQuestionSet.where(active: true).update_all(active: false)
    resource.update!(active: true)
    redirect_to admin_behavioral_learning_question_sets_path, notice: 'Question set is now active!'
  end

  # Add import button to index page
  action_item :import_google_sheets, only: :index do
    link_to 'Import from Google Sheets',
            import_from_google_sheets_admin_behavioral_learning_question_sets_path,
            class: 'button'
  end

  index do
    selectable_column
    id_column
    column :version
    column :name
    column :active
    column :questions_count do |question_set|
      question_set.behavioral_learning_questions.count
    end
    column :time_limit
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_behavioral_learning_question_set_path(resource), class: 'member_link'
      unless resource.active?
        item 'Make Active', make_active_admin_behavioral_learning_question_set_path(resource), method: :patch, class: 'member_link'
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :version
      row :name
      row :active
      row :time_limit
      row :created_at
      row :updated_at
    end

    panel 'Categories' do
      table_for resource.behavioral_learning_question_set_categories do
        column :category do |qsc|
          qsc.behavioral_learning_category.name
        end
        column :code do |qsc|
          qsc.behavioral_learning_category.code
        end
        column :questions_count do |qsc|
          qsc.behavioral_learning_category.behavioral_learning_questions.where(behavioral_learning_question_set: resource).count
        end
      end
    end

    panel 'Questions' do
      table_for resource.behavioral_learning_questions.includes(:behavioral_learning_category) do
        column :category do |question|
          question.behavioral_learning_category.code
        end
        column :body do |question|
          truncate(question.body, length: 100)
        end
      end
    end
  end
end
