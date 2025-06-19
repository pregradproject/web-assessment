ActiveAdmin.register VarkQuestionSet do
  permit_params :version, :name, :active

  # Add custom action for Google Sheets import
  collection_action :import_from_google_sheets, method: :get do
    render 'admin/import_google_sheets'
  end

  collection_action :process_google_sheets_import, method: :post do
    begin
      service = GoogleSheetsImportService.new(params[:google_sheets_url])
      question_set = service.import!

      redirect_to admin_vark_question_set_path(question_set),
                  notice: "Successfully imported #{question_set.vark_questions.count} questions from Google Sheets!"
    rescue => e
      redirect_to import_from_google_sheets_admin_vark_question_sets_path,
                  alert: "Import failed: #{e.message}"
    end
  end

  # Add import button to index page
  action_item :import_google_sheets, only: :index do
    link_to 'Import from Google Sheets',
            import_from_google_sheets_admin_vark_question_sets_path,
            class: 'button'
  end

  index do
    selectable_column
    id_column
    column :version
    column :name
    column :active
    column :questions_count do |question_set|
      question_set.vark_questions.count
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :version
      row :name
      row :active
      row :created_at
      row :updated_at
    end

    panel 'Categories' do
      table_for resource.vark_question_set_categories do
        column :category do |qsc|
          qsc.vark_category.name
        end
        column :code do |qsc|
          qsc.vark_category.code
        end
        column :time_limit_secs
        column :questions_count do |qsc|
          qsc.vark_category.vark_questions.where(vark_question_set: resource).count
        end
      end
    end

    panel 'Questions' do
      table_for resource.vark_questions.includes(:vark_category) do
        column :category do |question|
          question.vark_category.code
        end
        column :body do |question|
          truncate(question.body, length: 100)
        end
        column :max_weight
      end
    end
  end
end
