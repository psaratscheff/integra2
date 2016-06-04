json.array!(@pagos) do |pago|
  json.extract! pago, :id, :_id, :cuentaOrigen, :cuentaDestino, :monto
  json.url pago_url(pago, format: :json)
end
