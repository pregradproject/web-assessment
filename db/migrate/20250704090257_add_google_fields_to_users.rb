class AddGoogleFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_id, :string
    add_column :users, :auth_provider, :string, default: 'email'
    add_column :users, :google_email, :string

    add_index :users, :google_id, unique: true
    add_index :users, :auth_provider
    add_index :users, :google_email
  end
end
