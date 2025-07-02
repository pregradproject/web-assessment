class CreatePaymentTables < ActiveRecord::Migration[8.0]
  def change
    create_table :payments, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :order, null: false, foreign_key: true, type: :uuid
      t.string :payment_method
      t.string :midtrans_transaction_id
      t.string :midtrans_order_id
      t.string :snap_token
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, default: 0, null: false
      t.text :midtrans_response
      t.datetime :paid_at
      t.datetime :expires_at
      t.timestamps
    end

    add_index :payments, :midtrans_transaction_id
    add_index :payments, :midtrans_order_id
    add_index :payments, :status
  end
end
