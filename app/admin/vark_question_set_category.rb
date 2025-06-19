ActiveAdmin.register VarkQuestionSetCategory do
  menu parent: 'Vark'
  permit_params :vark_question_set_id, :vark_category_id, :time_limit_secs

  index do
    selectable_column
    id_column
    column :vark_question_set
    column :vark_category
    column :time_limit_secs
    actions
  end

  filter :vark_question_set
  filter :vark_category

  form do |f|
    f.inputs 'Set‑Category Mapping' do
      f.input :vark_question_set
      f.input :vark_category
      f.input :time_limit_secs
    end
    f.actions
  end
end
