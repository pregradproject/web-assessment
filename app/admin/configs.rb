ActiveAdmin.register Config do
  menu label: 'Configs', priority: 10

  permit_params :key, :value, :description, :value_type

  index do
    selectable_column
    id_column
    column :key
    column :value
    column :value_type
    column :description
    column :created_at
    column :updated_at
    actions
  end

  filter :key
  filter :value_type, as: :select, collection: %w[string integer float boolean]
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs 'Config Details' do
      f.input :key, hint: 'Unique identifier for this configs (e.g., vark_price)'
      f.input :value, hint: 'The configuration value'
      f.input :value_type, as: :select, collection: %w[string integer float boolean],
              hint: 'Data type of the value'
      f.input :description, hint: 'Optional description of what this configs does'
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :key
      row :value
      row :value_type
      row :typed_value do |config|
        config.typed_value
      end
      row :description
      row :created_at
      row :updated_at
    end
  end

  after_save do |config|
    # Clear cache when configs is updated
    Configs::ConfigServices.clear_cache(config.key)
  end

  after_destroy do |config|
    # Clear cache when configs is deleted
    Configs::ConfigServices.clear_cache(config.key)
  end
end
