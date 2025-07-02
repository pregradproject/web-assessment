class CreateOrderTables < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :testable, polymorphic: true, null: false, type: :uuid
      t.string :order_number, null: false
      t.integer :category, default: 0, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, default: 0, null: false
      t.datetime :expires_at
      t.text :description
      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :status
  end
end
