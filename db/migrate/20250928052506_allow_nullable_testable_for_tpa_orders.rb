class AllowNullableTestableForTpaOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :testable_id, true
    change_column_null :orders, :testable_type, true
  end
end
