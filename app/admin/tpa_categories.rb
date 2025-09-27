ActiveAdmin.register TpaCategory do
  menu parent: 'TPA Management', priority: 1
  permit_params :name, :code, :description

  index do
    selectable_column
    id_column
    column :name
    column :code
    column :description
    column :created_at
    actions
  end

  filter :name
  filter :code
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :code, hint: 'Single letter code (V, Q, A, S)'
      f.input :description
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :code
      row :description
      row :created_at
      row :updated_at
    end

    panel 'Questions' do
      table_for tpa_category.tpa_questions.includes(:tpa_question_set) do
        column :id
        column :question_text do |question|
          truncate(question.question_text, length: 100)
        end
        column :difficulty_level
        column :question_set do |question|
          question.tpa_question_set.name
        end
        column :actions do |question|
          link_to 'View', admin_tpa_question_path(question)
        end
      end
    end
  end
end
