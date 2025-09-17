class ChangeExpiryDateToNullableInCoupons < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:coupons, :expiry_date)
      column = connection.columns(:coupons).find { |c| c.name == 'expiry_date' }
      unless column&.null
        change_column_null :coupons, :expiry_date, true
      end
    end
  end
end