ActiveAdmin.register Signature do
  permit_params :name, :department, :signature_image, :status

  index do
    selectable_column
    id_column
    column :name
    column :department
    column :status
    column :signature_image do |signature|
      if signature.signature_image.attached?
        image_tag url_for(signature.signature_image), size: '100x50'
      end
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :department
  filter :status, as: :select, collection: Signature.statuses.keys
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :department
      f.input :status, as: :select, collection: Signature.statuses.keys.map { |status| [ status.humanize, status ] }
      f.input :signature_image, as: :file, hint: f.object.signature_image.attached? ? image_tag(url_for(f.object.signature_image), size: '100x50') : ''
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :department
      row :status
      row :signature_image do |signature|
        if signature.signature_image.attached?
          image_tag url_for(signature.signature_image), size: '200x100'
        end
      end
      row :created_at
      row :updated_at
    end
  end
end
