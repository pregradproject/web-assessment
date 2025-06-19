
ActiveAdmin.register VarkQuestion do
  menu parent: 'Vark'
  permit_params :vark_question_set_id, :vark_category_id, :body

  index do
    selectable_column
    id_column
    column :vark_question_set
    column :vark_category
    column :body
    column :max_weight
    actions
  end

  filter :vark_question_set
  filter :vark_category
  filter :body

  form do |f|
    f.inputs 'Question' do
      f.input :vark_question_set
      f.input :vark_category
      f.input :body
      f.input :max_weight
    end
    f.actions
  end
end
