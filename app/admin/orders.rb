ActiveAdmin.register Order do
  menu parent: 'Commerce', priority: 2

  actions :index, :show

  permit_params :user_id, :testable_type, :testable_id, :order_number, :amount, :category, :status,
                :certificate_status, :expires_at, :certificate_generated_at

  # Filters
  filter :user, as: :select, collection: -> { User.order(:name) }
  filter :order_number
  filter :status, as: :select, collection: Order.statuses
  filter :category, as: :select, collection: Order.categories
  filter :certificate_status, as: :select, collection: Order.certificate_statuses
  filter :amount
  filter :expires_at
  filter :certificate_generated_at
  filter :created_at
  filter :updated_at

  # Scopes
  scope :all
  scope :pending
  scope :paid
  scope :cancelled
  scope :expired

  # Index page
  index do
    selectable_column
    id_column
    column :order_number do |order|
      link_to order.order_number, admin_order_path(order)
    end
    column 'User' do |order|
      link_to order.user.name, admin_user_path(order.user) if order.user.present?
    end
    column :amount do |order|
      number_to_currency(order.amount, unit: 'Rp ', separator: ',', delimiter: '.')
    end
    column :status do |order|
      status_tag order.status
    end
    column :category
    column :certificate_status do |order|
      status_tag order.certificate_status
    end
    column 'Testable' do |order|
      if order.testable.present?
        case order.testable_type
        when 'VarkTest'
          link_to 'VARK Test', admin_vark_test_path(order.testable)
        else
          "#{order.testable_type} ##{order.testable_id}"
        end
      else
        '-'
      end
    end
    column 'Payments Count' do |order|
      order.payments.count
    end
    column 'Successful Payment' do |order|
      order.successful_payment.present? ? status_tag('Yes', class: 'ok') : status_tag('No', class: 'error')
    end
    column 'Certificate Ready' do |order|
      if order.certificate_ready?
        status_tag('Yes', class: 'ok')
      else
        status_tag('No', class: 'error')
      end
    end
    column :expires_at
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_order_path(resource), class: 'view_link'
    end
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :order_number
      row 'User' do |order|
        link_to order.user.name, admin_user_path(order.user) if order.user.present?
      end
      row :amount do |order|
        number_to_currency(order.amount, unit: 'Rp ', separator: ',', delimiter: '.')
      end
      row :status do |order|
        status_tag order.status
      end
      row :category
      row :certificate_status do |order|
        status_tag order.certificate_status
      end
      row 'Testable' do |order|
        if order.testable.present?
          case order.testable_type
          when 'VarkTest'
            link_to 'VARK Test', admin_vark_test_path(order.testable)
          else
            "#{order.testable_type} ##{order.testable_id}"
          end
        else
          '-'
        end
      end
      row 'Paid?' do |order|
        order.paid? ? status_tag('Yes', class: 'ok') : status_tag('No', class: 'error')
      end
      row 'Expired?' do |order|
        order.expired? ? status_tag('Yes', class: 'error') : status_tag('No', class: 'ok')
      end
      row 'Certificate Ready?' do |order|
        if order.certificate_ready?
          status_tag('Yes', class: 'ok')
        else
          status_tag('No', class: 'error')
        end
      end
      row 'Can Download Certificate?' do |order|
        if order.can_download_certificate?
          status_tag('Yes', class: 'ok')
        else
          status_tag('No', class: 'error')
        end
      end
      row :expires_at
      row :certificate_generated_at
      row :created_at
      row :updated_at
    end

    # Certificate section
    if resource.certificate_pdf.present?
      panel 'Certificate' do
        attributes_table do
          row 'Certificate File' do |order|
            if order.certificate_pdf.attached?
              link_to 'Download Certificate', rails_blob_path(order.certificate_pdf, disposition: 'attachment')
            else
              'No certificate attached'
            end
          end
          row 'Certificate Size' do |order|
            if order.certificate_pdf.attached?
              number_to_human_size(order.certificate_pdf.byte_size)
            else
              '-'
            end
          end
          row 'Certificate Content Type' do |order|
            if order.certificate_pdf.attached?
              order.certificate_pdf.content_type
            else
              '-'
            end
          end
        end
      end
    end

    # Payments section
    if resource.payments.any?
      panel 'Payments' do
        table_for resource.payments do
          column :id do |payment|
            link_to payment.id, admin_payment_path(payment)
          end
          column :amount do |payment|
            number_to_currency(payment.amount, unit: 'Rp ', separator: ',', delimiter: '.')
          end
          column :payment_method
          column :status do |payment|
            status_tag payment.status
          end
          column :midtrans_transaction_id
          column :paid_at
          column :expires_at
          column :created_at
        end
      end
    end

    # Successful Payment section
    if resource.successful_payment.present?
      panel 'Successful Payment Details' do
        attributes_table_for resource.successful_payment do
          row :id
          row :amount do |payment|
            number_to_currency(payment.amount, unit: 'Rp ', separator: ',', delimiter: '.')
          end
          row :payment_method
          row :status do |payment|
            status_tag payment.status
          end
          row :midtrans_transaction_id
          row :midtrans_order_id
          row :paid_at
          row :created_at
        end
      end
    end

    active_admin_comments
  end

  # Form
  form do |f|
    f.inputs 'Order Details' do
      f.input :user, as: :select, collection: User.order(:name)
      f.input :order_number
      f.input :amount
      f.input :category, as: :select, collection: Order.categories
      f.input :status, as: :select, collection: Order.statuses
      f.input :certificate_status, as: :select, collection: Order.certificate_statuses
      f.input :expires_at, as: :datepicker
      f.input :certificate_generated_at, as: :datepicker
    end
    f.actions
  end

  # Custom actions
  member_action :mark_as_paid, method: :patch do
    if resource.pending?
      resource.update!(status: 'paid')
      redirect_to admin_order_path(resource), notice: 'Order marked as paid.'
    else
      redirect_to admin_order_path(resource), alert: 'Order is not pending.'
    end
  end

  member_action :cancel_order, method: :patch do
    if resource.pending?
      resource.update!(status: 'cancelled')
      redirect_to admin_order_path(resource), notice: 'Order cancelled.'
    else
      redirect_to admin_order_path(resource), alert: 'Order cannot be cancelled.'
    end
  end

  member_action :regenerate_certificate, method: :patch do
    if resource.paid?
      resource.update!(certificate_status: 'pending_generation')
      # Here you would typically enqueue a job to regenerate the certificate
      GenerateCertificateJob.perform_later(resource.id)
      redirect_to admin_order_path(resource), notice: 'Certificate regeneration queued.'
    else
      redirect_to admin_order_path(resource), alert: 'Order must be paid to regenerate certificate.'
    end
  end

  action_item :mark_as_paid, only: :show, if: proc { resource.pending? } do
    link_to 'Mark as Paid', mark_as_paid_admin_order_path(resource), method: :patch,
            confirm: 'Are you sure you want to mark this order as paid?'
  end

  action_item :cancel_order, only: :show, if: proc { resource.pending? } do
    link_to 'Cancel Order', cancel_order_admin_order_path(resource), method: :patch,
            confirm: 'Are you sure you want to cancel this order?'
  end

  action_item :regenerate_certificate, only: :show, if: proc { resource.paid? } do
    link_to 'Regenerate Certificate', regenerate_certificate_admin_order_path(resource), method: :patch,
            confirm: 'Are you sure you want to regenerate the certificate?'
  end

  # Batch actions
  batch_action :mark_as_paid do |ids|
    batch_action_collection.find(ids).each do |order|
      if order.pending?
        order.update!(status: 'paid')
      end
    end
    redirect_to collection_path, notice: 'Selected orders marked as paid.'
  end

  batch_action :cancel_orders do |ids|
    batch_action_collection.find(ids).each do |order|
      if order.pending?
        order.update!(status: 'cancelled')
      end
    end
    redirect_to collection_path, notice: 'Selected orders cancelled.'
  end

  # CSV export
  csv do
    column :id
    column :order_number
    column('User') { |order| order.user.name }
    column('User Email') { |order| order.user.email }
    column :amount
    column :status
    column :category
    column :certificate_status
    column('Testable Type') { |order| order.testable_type }
    column('Testable ID') { |order| order.testable_id }
    column('Paid') { |order| order.paid? }
    column('Expired') { |order| order.expired? }
    column('Certificate Ready') { |order| order.certificate_ready? }
    column('Payments Count') { |order| order.payments.count }
    column('Successful Payment ID') { |order| order.successful_payment&.id }
    column :expires_at
    column :certificate_generated_at
    column :created_at
    column :updated_at
  end
end
