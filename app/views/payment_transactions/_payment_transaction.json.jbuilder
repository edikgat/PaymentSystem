json.extract! payment_transaction, :id, :uuid, :merchant_id, :payment_transaction_id, :status, :type, :amount, :customer_email, :customer_phone, :created_at, :updated_at
json.url payment_transaction_url(payment_transaction, format: :json)
