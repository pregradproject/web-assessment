ActiveAdmin.register ComprehensiveAssessmentCategory do
  menu parent: 'Comprehensive Assessment'
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
    f.inputs 'Comprehensive Assessment Category Details' do
      f.input :code
      f.input :name
      f.input :description
    end
    f.actions
  end
end
