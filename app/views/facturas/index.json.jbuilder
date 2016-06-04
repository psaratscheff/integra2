json.array!(@facturas) do |factura|
  json.extract! factura, :id, :_id, :proveedor, :cliente, :valorTotal, :estadoPago, :idoc, :comentario
  json.url factura_url(factura, format: :json)
end
