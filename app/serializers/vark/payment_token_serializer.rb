module Vark
  class PaymentTokenSerializer < ApplicationSerializer
    attributes :id,
               :snap_token,
               :order_id,
               :midtrans_order_id,
               :status,
               :amount,
               :paid_at,
               :expires_at,
               :midtrans_transaction_id,
               :midtrans_response
  end
end
