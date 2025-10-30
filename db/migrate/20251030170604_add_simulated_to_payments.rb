class AddSimulatedToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :simulated, :boolean, default: false, null: false
  end
end
