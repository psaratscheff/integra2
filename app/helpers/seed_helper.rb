module SeedHelper

  def stock_de_almacen(almacenId, sku)
    require 'httparty'
    puts "Almacen id= " + almacenId.to_s
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Stock de Almacen--------------"
      result = HTTParty.get($urlBodega+"stock"+"?almacenId="+almacenId+"&"+"sku="+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId.to_s+sku.to_s)
              })
      puts "(Stock_de_Almacen)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Stock de Almacen Obtenido--------------"
      sleep(10) # Sleep 10 seconds...
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1013"
      render json: { error: ex.message }, status: 503 and return
    end
  end
  def lista_de_almacenes()
    require 'httparty'
    puts "--------Obteniendo Lista de Almacenes--------------"
    result = HTTParty.get($urlBodega +"almacenes",
            headers: {
              'Content-Type' => 'application/json',
              'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET')
            })
    puts "(Lista_de_Almacenes)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)
    puts "--------Lista de Almacenes Obtenida--------------"
    sleep(10) # Sleep 10 seconds...
    return json
  end
  def productos_almacen(almacenId)
    skus = [2,12,15,20,21,25,28,32,37]
    productos = []
    skus.each do |sku|
      listaProductos = stock_de_almacen(almacenId,sku)
      listaProductos.each do |producto|
        productos.append(producto)
      end
    end
    return productos
  end

end
