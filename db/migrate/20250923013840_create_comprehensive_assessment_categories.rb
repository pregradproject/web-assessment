class CreateComprehensiveAssessmentCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :comprehensive_assessment_categories, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :comprehensive_assessment_categories, :code, unique: true
  end
end
