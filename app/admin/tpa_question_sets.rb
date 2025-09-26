ActiveAdmin.register TpaQuestionSet do
  permit_params :name, :version, :active, :time_limit

  index do
    selectable_column
    id_column
    column :name
    column :version
    column :active do |question_set|
      status_tag question_set.active? ? 'Active' : 'Inactive',
                 question_set.active? ? :ok : :error
    end
    column :time_limit do |question_set|
      "#{question_set.time_limit} minutes"
    end
    column :total_questions do |question_set|
      question_set.tpa_questions.count
    end
    column :created_at
    actions
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
        status_tag question_set.active? ? 'Active' : 'Inactive',
                   question_set.active? ? :ok : :error
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
      table_for tpa_question_set.questions_by_category do
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