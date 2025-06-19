ActiveAdmin.register VarkCategory do
  menu parent: 'Vark'
  permit_params :code, :name, :description, :result_text

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :description
    column :result_text
    actions
  end

  filter :code
  filter :name

  form do |f|
    f.inputs 'VARK Category Details' do
      f.input :code
      f.input :name
      f.input :description
      f.input :result_text
    end
    f.actions
  end
end
