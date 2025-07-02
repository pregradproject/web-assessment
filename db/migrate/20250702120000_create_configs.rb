class CreateConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :configs, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :key, null: false
      t.text :value, null: false
      t.text :description
      t.string :value_type, default: 'string', null: false
      t.timestamps
    end

    add_index :configs, :key, unique: true
  end
end
