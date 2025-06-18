ActiveAdmin.register User do
  permit_params :name, :email, :birthday, :phone, :avatar

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :birthday
    column :phone
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :email
  filter :birthday
  filter :phone

  show do
    attributes_table do
      row :id
      row :name
      row :email
      row :birthday
      row :phone
      row :created_at
      row :updated_at
      row :avatar do |user|
        if user.avatar.attached?
          image_tag url_for(user.avatar), size: '100x100'
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :birthday, as: :datepicker
      f.input :phone
      f.input :avatar, as: :file
    end
    f.actions
  end
end
