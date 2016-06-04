json.array!(@almacens) do |almacen|
  json.extract! almacen, :id, :pulmon, :despacho, :recepcion, :espacioTotal, :espacioUtilizado, :_id
  json.url almacen_url(almacen, format: :json)
end
