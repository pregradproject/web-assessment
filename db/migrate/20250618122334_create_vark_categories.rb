class CreateVarkCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :vark_categories, id: :uuid do |t|
      t.string  :code, limit: 1, null: false
      t.string  :name
      t.string  :description
      t.string  :result_text
      t.timestamps
    end

    add_index :vark_categories, :code, unique: true
  end
end
