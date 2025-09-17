ActiveAdmin.register CouponUsage do
  actions :index, :show

  filter :coupon, collection: -> { Coupon.all.map { |c| [ c.code, c.id ] } }
  filter :user
  filter :order
  filter :discount_amount
  filter :created_at

  index do
    selectable_column
    id_column
    column :coupon do |usage|
      link_to usage.coupon.code, admin_coupon_path(usage.coupon) if usage.coupon
    end
    column :user do |usage|
      link_to usage.user.name, admin_user_path(usage.user) if usage.user
    end
    column :order do |usage|
      link_to usage.order_number, admin_order_path(usage.order) if usage.order
    end
    column :discount_amount do |usage|
      "Rp #{usage.discount_amount}"
    end
    column :created_at
    actions defaults: false do |usage|
      link_to 'View', admin_coupon_usage_path(usage), class: 'member_link'
    end
  end

  show do
    attributes_table do
      row :id
      row :coupon do |usage|
        link_to usage.coupon.code, admin_coupon_path(usage.coupon) if usage.coupon
      end
      row :user do |usage|
        link_to usage.user.name, admin_user_path(usage.user) if usage.user
      end
      row :order do |usage|
        link_to usage.order_number, admin_order_path(usage.order) if usage.order
      end
      row :discount_amount do |usage|
        "Rp #{usage.discount_amount}"
      end
      row :created_at
      row :updated_at
    end

    panel 'Coupon Details' do
      attributes_table_for coupon_usage.coupon do
        row :code
        row :discount_type do |coupon|
          coupon.discount_type.humanize
        end
        row :discount_value
        row :display_discount
        row :max_usage_per_user
        row :expires_at
        row :active
      end
    end

    panel 'Order Details' do
      attributes_table_for coupon_usage.order do
        row :order_number
        row :amount do |order|
          "Rp #{order.amount}"
        end
        row :original_amount do |order|
          "Rp #{order.original_amount}" if order.original_amount
        end
        row :status do |order|
          order.status.humanize
        end
        row :created_at
      end
    end
  end

  csv do
    column :id
    column :coupon_code do |usage|
      usage.coupon_code
    end
    column :user_name do |usage|
      usage.user_name
    end
    column :order_number do |usage|
      usage.order_number
    end
    column :discount_amount
    column :created_at
    column :updated_at
  end
end
