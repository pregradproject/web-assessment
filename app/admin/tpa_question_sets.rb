ActiveAdmin.register TpaQuestionSet do
  menu parent: 'TPA Management', priority: 2
  permit_params :name, :version, :active, :time_limit

  config.clear_action_items!

  collection_action :import_from_google_sheets, method: :get do
    render 'admin/import_google_sheets_tpa'
  end

  collection_action :process_google_sheets_import, method: :post do
    begin
      service = TpaGoogleSheetsImportService.new(params[:google_sheets_url], params[:time_limit])
      question_set = service.import!

      redirect_to admin_tpa_question_set_path(question_set),
                  notice: "Successfully imported #{question_set.tpa_questions.count} questions from Google Sheets!"
    rescue => e
      redirect_to import_from_google_sheets_admin_tpa_question_sets_path,
                  alert: "Import failed: #{e.message}"
    end
  end

  member_action :make_active, method: :patch do
    TpaQuestionSet.where(active: true).update_all(active: false)
    resource.update!(active: true)
    redirect_to admin_tpa_question_sets_path, notice: 'Question set is now active!'
  end

  # Add import button to index page
  action_item :import_google_sheets, only: :index do
    link_to 'Import from Google Sheets',
            import_from_google_sheets_admin_tpa_question_sets_path,
            class: 'button'
  end

  index do
    selectable_column
    id_column
    column :name
    column :version
    column :active do |question_set|
      question_set.active? ? 'Active' : 'Inactive'
    end
    column :time_limit do |question_set|
      "#{question_set.time_limit} minutes"
    end
    column :total_questions do |question_set|
      question_set.tpa_questions.count
    end
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_tpa_question_set_path(resource), class: 'member_link'
      unless resource.active?
        item 'Make Active', make_active_admin_tpa_question_set_path(resource), method: :patch, class: 'member_link'
      end
    end
  end

  filter :name
  filter :version
  filter :active
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :version
      f.input :active, hint: 'Only one question set can be active at a time'
      f.input :time_limit, hint: 'Time limit in minutes'
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :version
      row :active do |question_set|
        status_tag question_set.active? ? 'Active' : 'Inactive'
      end
      row :time_limit do |question_set|
        "#{question_set.time_limit} minutes"
      end
      row :total_questions do |question_set|
        question_set.tpa_questions.count
      end
      row :created_at
      row :updated_at
    end

    panel 'Questions by Category' do
      table_for tpa_question_set.questions_by_category.to_a do
        column 'Category', &:first
        column 'Count', &:second
      end
    end

    panel 'Questions' do
      table_for tpa_question_set.tpa_questions.includes(:tpa_category) do
        column :id
        column :category do |question|
          question.tpa_category.name
        end
        column :question_text do |question|
          truncate(question.question_text, length: 100)
        end
        column :difficulty_level
        column :actions do |question|
          link_to 'View', admin_tpa_question_path(question)
        end
      end
    end
  end
end
