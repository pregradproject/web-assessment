class CreateTpaCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :tpa_categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false, limit: 2
      t.text :description, limit: 500

      t.timestamps
    end

    add_index :tpa_categories, :name, unique: true
    add_index :tpa_categories, :code, unique: true
  end
end
