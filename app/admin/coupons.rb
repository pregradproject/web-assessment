ActiveAdmin.register Coupon do
  permit_params :code, :name, :description, :discount_type, :discount_value, :max_uses_per_user, :expiry_date, :active

  filter :code
  filter :name
  filter :discount_type
  filter :active
  filter :expiry_date
  filter :created_at

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :discount_type do |coupon|
      coupon.discount_type.humanize
    end
    column :discount_value
    column :display_discount
    column :max_uses_per_user
    column :expiry_date
    column :active
    column :usage_count do |coupon|
      coupon.coupon_usages.count
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :code
      row :name
      row :description
      row :discount_type do |coupon|
        coupon.discount_type.humanize
      end
      row :discount_value
      row :display_discount
      row :max_uses_per_user
      row :expiry_date
      row :active
      row :created_at
      row :updated_at
    end

    panel 'Usage Statistics' do
      table_for coupon.coupon_usages.includes(:user, :order).recent.limit(10) do
        column 'User' do |usage|
          link_to usage.user.name, admin_user_path(usage.user) if usage.user
        end
        column 'Order' do |usage|
          link_to usage.order_number, admin_order_path(usage.order) if usage.order
        end
        column :discount_amount do |usage|
          "Rp #{usage.discount_amount}"
        end
        column :created_at
      end
    end
  end

  form do |f|
    f.inputs 'Coupon Details' do
      f.input :code, hint: 'Coupon code (will be converted to uppercase)'
      f.input :name, hint: 'Display name for the coupon'
      f.input :description, hint: 'Description of the coupon offer'
      f.input :discount_type, as: :select, collection: Coupon.discount_types.map { |key, value| [ key.humanize, key ] }
      f.input :discount_value, hint: 'For percentage: enter 1-100, for fixed: enter amount in rupiah'
      f.input :max_uses_per_user, hint: 'Maximum number of times each user can use this coupon'
      f.input :expiry_date, as: :datetime_picker, hint: 'Leave blank for no expiration'
      f.input :active
    end
    f.actions
  end

  csv do
    column :id
    column :code
    column :name
    column :description
    column :discount_type
    column :discount_value
    column :max_uses_per_user
    column :expiry_date
    column :active
    column :created_at
    column :updated_at
    column :usage_count do |coupon|
      coupon.coupon_usages.count
    end
  end
end
