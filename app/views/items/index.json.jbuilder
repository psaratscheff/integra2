json.array!(@items) do |item|
  json.extract! item, :id, :Sku, :Descripcion, :Tipo, :Grupo, :Unidades, :CostoUnitario, :Lote, :TiempoMedio, :PrecioUnitario, :Sku1, :Sku2, :Sku3, :Sku4
  json.url item_url(item, format: :json)
end
