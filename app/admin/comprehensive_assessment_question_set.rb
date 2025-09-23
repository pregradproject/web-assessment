ActiveAdmin.register ComprehensiveAssessmentQuestionSet do
  permit_params :version, :name, :active, :time_limit

  config.clear_action_items!

  collection_action :import_from_google_sheets, method: :get do
    render 'admin/import_google_sheets'
  end

  collection_action :process_google_sheets_import, method: :post do
    begin
      service = ComprehensiveAssessmentGoogleSheetsImportService.new(params[:google_sheets_url], params[:time_limit])
      question_set = service.import!

      redirect_to admin_comprehensive_assessment_question_set_path(question_set),
                  notice: "Successfully imported #{question_set.comprehensive_assessment_questions.count} questions from Google Sheets!"
    rescue => e
      redirect_to import_from_google_sheets_admin_comprehensive_assessment_question_sets_path,
                  alert: "Import failed: #{e.message}"
    end
  end

  member_action :make_active, method: :patch do
    ComprehensiveAssessmentQuestionSet.where(active: true).update_all(active: false)
    resource.update!(active: true)
    redirect_to admin_comprehensive_assessment_question_sets_path, notice: 'Question set is now active!'
  end

  # Add import button to index page
  action_item :import_google_sheets, only: :index do
    link_to 'Import from Google Sheets',
            import_from_google_sheets_admin_comprehensive_assessment_question_sets_path,
            class: 'button'
  end

  index do
    selectable_column
    id_column
    column :version
    column :name
    column :active
    column :questions_count do |question_set|
      question_set.comprehensive_assessment_questions.count
    end
    column :time_limit
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_comprehensive_assessment_question_set_path(resource), class: 'member_link'
      unless resource.active?
        item 'Make Active', make_active_admin_comprehensive_assessment_question_set_path(resource), method: :patch, class: 'member_link'
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
      table_for resource.comprehensive_assessment_question_set_categories do
        column :category do |qsc|
          qsc.comprehensive_assessment_category.name
        end
        column :code do |qsc|
          qsc.comprehensive_assessment_category.code
        end
        column :questions_count do |qsc|
          qsc.comprehensive_assessment_category.comprehensive_assessment_questions.where(comprehensive_assessment_question_set: resource).count
        end
      end
    end

    panel 'Questions' do
      table_for resource.comprehensive_assessment_questions.includes(:comprehensive_assessment_category) do
        column :category do |question|
          question.comprehensive_assessment_category.code
        end
        column :body do |question|
          truncate(question.body, length: 100)
        end
      end
    end
  end
end
