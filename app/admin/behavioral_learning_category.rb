ActiveAdmin.register BehavioralLearningCategory do
  menu parent: 'Behavioral Learning'
  permit_params :code, :name, :description

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :description
    actions
  end

  filter :code
  filter :name

  form do |f|
    f.inputs 'Behavioral Learning Category Details' do
      f.input :code
      f.input :name
      f.input :description
    end
    f.actions
  end
end
