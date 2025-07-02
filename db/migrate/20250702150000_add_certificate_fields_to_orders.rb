class AddCertificateFieldsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :certificate_generated_at, :datetime
    add_column :orders, :certificate_status, :integer, default: 0
    add_column :orders, :certificate_generation_error, :text

    add_index :orders, :certificate_status
  end
end
