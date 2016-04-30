json.array!(@ocs) do |oc|
  json.extract! oc, :id, :idoc, :idfactura, :estado, :fechaRecepcion, :fechaEntrega, :canal, :cliente, :proveedor, :sku, :cantidad, :cantidadDespachada
  json.url oc_url(oc, format: :json)
end
