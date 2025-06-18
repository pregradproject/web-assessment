class CreateSignatures < ActiveRecord::Migration[8.0]
  def change
    create_table :signatures, id: :uuid do |t|
      t.string :name, null: false
      t.string :department, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end
