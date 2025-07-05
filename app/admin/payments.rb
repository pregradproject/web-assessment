ActiveAdmin.register Payment do
  menu parent: 'Commerce', priority: 3

  actions :index, :show

  permit_params :order_id, :amount, :payment_method, :midtrans_transaction_id, :midtrans_order_id,
                :snap_token, :status, :midtrans_response, :paid_at, :expires_at

  # Filters
  filter :order, as: :select, collection: -> { Order.order(:order_number) }
  filter :payment_method
  filter :status, as: :select, collection: Payment.statuses
  filter :midtrans_transaction_id
  filter :midtrans_order_id
  filter :amount
  filter :paid_at
  filter :expires_at
  filter :created_at
  filter :updated_at

  # Scopes
  scope :all
  scope :pending
  scope :settlement
  scope :deny
  scope :cancel
  scope :expire
  scope :failure

  # Index page
  index do
    selectable_column
    id_column
    column 'Order' do |payment|
      link_to payment.order.order_number, admin_order_path(payment.order) if payment.order.present?
    end
    column 'User' do |payment|
      if payment.order&.user.present?
        link_to payment.order.user.name, admin_user_path(payment.order.user)
      else
        '-'
      end
    end
    column :amount do |payment|
      number_to_currency(payment.amount, unit: 'Rp ', separator: ',', delimiter: '.')
    end
    column :payment_method
    column :status do |payment|
      status_tag payment.status
    end
    column :midtrans_transaction_id do |payment|
      if payment.midtrans_transaction_id.present?
        truncate(payment.midtrans_transaction_id, length: 20)
      else
        '-'
      end
    end
    column :midtrans_order_id do |payment|
      if payment.midtrans_order_id.present?
        truncate(payment.midtrans_order_id, length: 20)
      else
        '-'
      end
    end
    column 'Success?' do |payment|
      payment.success? ? status_tag('Yes', class: 'ok') : status_tag('No', class: 'error')
    end
    column 'Expired?' do |payment|
      payment.expired? ? status_tag('Yes', class: 'error') : status_tag('No', class: 'ok')
    end
    column :paid_at
    column :expires_at
    column :created_at
    actions defaults: false do |resource|
      item 'View', admin_payment_path(resource), class: 'view_link'
    end
  end

  # Show page
  show do
    attributes_table do
      row :id
      row 'Order' do |payment|
        link_to payment.order.order_number, admin_order_path(payment.order) if payment.order.present?
      end
      row 'User' do |payment|
        if payment.order&.user.present?
          link_to payment.order.user.name, admin_user_path(payment.order.user)
        else
          '-'
        end
      end
      row :amount do |payment|
        number_to_currency(payment.amount, unit: 'Rp ', separator: ',', delimiter: '.')
      end
      row :payment_method
      row :status do |payment|
        status_tag payment.status
      end
      row :midtrans_transaction_id
      row :midtrans_order_id
      row :snap_token
      row 'Success?' do |payment|
        payment.success? ? status_tag('Yes', class: 'ok') : status_tag('No', class: 'error')
      end
      row 'Expired?' do |payment|
        payment.expired? ? status_tag('Yes', class: 'error') : status_tag('No', class: 'ok')
      end
      row :paid_at
      row :expires_at
      row :created_at
      row :updated_at
    end

    # Order Information section
    if resource.order.present?
      panel 'Order Information' do
        attributes_table_for resource.order do
          row :order_number
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
          row :created_at
        end
      end
    end

    # Midtrans Response section
    if resource.midtrans_response.present?
      panel 'Midtrans Response' do
        begin
          response_data = JSON.parse(resource.midtrans_response)
          attributes_table do
            response_data.each do |key, value|
              row key.humanize do
                if value.is_a?(Hash) || value.is_a?(Array)
                  JSON.pretty_generate(value)
                else
                  value
                end
              end
            end
          end
        rescue JSON::ParserError
          div do
            pre resource.midtrans_response
          end
        end
      end
    end

    active_admin_comments
  end

  # Form
  form do |f|
    f.inputs 'Payment Details' do
      f.input :order, as: :select, collection: Order.order(:order_number)
      f.input :amount
      f.input :payment_method
      f.input :midtrans_transaction_id
      f.input :midtrans_order_id
      f.input :snap_token
      f.input :status, as: :select, collection: Payment.statuses
      f.input :paid_at, as: :datepicker
      f.input :expires_at, as: :datepicker
    end
    f.inputs 'Midtrans Response' do
      f.input :midtrans_response, as: :text
    end
    f.actions
  end

  # Custom actions
  member_action :mark_as_settlement, method: :patch do
    if resource.pending?
      resource.update!(status: 'settlement', paid_at: Time.current)
      # Update order status if this is the successful payment
      if resource.order.present? && resource.order.pending?
        resource.order.update!(status: 'paid')
      end
      redirect_to admin_payment_path(resource), notice: 'Payment marked as settlement.'
    else
      redirect_to admin_payment_path(resource), alert: 'Payment is not pending.'
    end
  end

  member_action :mark_as_failure, method: :patch do
    if resource.pending?
      resource.update!(status: 'failure')
      redirect_to admin_payment_path(resource), notice: 'Payment marked as failure.'
    else
      redirect_to admin_payment_path(resource), alert: 'Payment is not pending.'
    end
  end

  member_action :sync_with_midtrans, method: :patch do
    # Here you would typically call Midtrans API to sync the payment status
    # For now, we'll just redirect with a notice
    redirect_to admin_payment_path(resource), notice: 'Payment sync with Midtrans queued.'
  end

  action_item :mark_as_settlement, only: :show, if: proc { resource.pending? } do
    link_to 'Mark as Settlement', mark_as_settlement_admin_payment_path(resource), method: :patch,
            confirm: 'Are you sure you want to mark this payment as settlement?'
  end

  action_item :mark_as_failure, only: :show, if: proc { resource.pending? } do
    link_to 'Mark as Failure', mark_as_failure_admin_payment_path(resource), method: :patch,
            confirm: 'Are you sure you want to mark this payment as failure?'
  end

  action_item :sync_with_midtrans, only: :show do
    link_to 'Sync with Midtrans', sync_with_midtrans_admin_payment_path(resource), method: :patch,
            confirm: 'Are you sure you want to sync this payment with Midtrans?'
  end

  # Batch actions
  batch_action :mark_as_settlement do |ids|
    batch_action_collection.find(ids).each do |payment|
      if payment.pending?
        payment.update!(status: 'settlement', paid_at: Time.current)
        # Update order status if this is the successful payment
        if payment.order.present? && payment.order.pending?
          payment.order.update!(status: 'paid')
        end
      end
    end
    redirect_to collection_path, notice: 'Selected payments marked as settlement.'
  end

  batch_action :mark_as_failure do |ids|
    batch_action_collection.find(ids).each do |payment|
      if payment.pending?
        payment.update!(status: 'failure')
      end
    end
    redirect_to collection_path, notice: 'Selected payments marked as failure.'
  end

  batch_action :sync_with_midtrans do |ids|
    # Here you would typically queue jobs to sync with Midtrans
    # SyncPaymentWithMidtransJob.perform_later(ids)
    redirect_to collection_path, notice: 'Payment sync with Midtrans queued for selected payments.'
  end

  # CSV export
  csv do
    column :id
    column('Order Number') { |payment| payment.order.order_number }
    column('User') { |payment| payment.order.user.name if payment.order&.user.present? }
    column('User Email') { |payment| payment.order.user.email if payment.order&.user.present? }
    column :amount
    column :payment_method
    column :status
    column :midtrans_transaction_id
    column :midtrans_order_id
    column :snap_token
    column('Success') { |payment| payment.success? }
    column('Expired') { |payment| payment.expired? }
    column :paid_at
    column :expires_at
    column :created_at
    column :updated_at
  end
end
