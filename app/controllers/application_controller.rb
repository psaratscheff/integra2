class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  $groupid = "571262b8a980ba030058ab50"
  $bancoid = "571262c3a980ba030058ab5c"

  private

  def despachar(idtrx,idfactura) #TODO: Revisar si este método va aquí

    factura = obtener_factura(idfactura)
    transaccion = obtener_transaccion(idtrx)

    #OC ID
    id_oc = factura['idoc']  #TODO ver si esta bien la sitaxis
    oc = obtener_oc(id_oc)
    sku = oc['sku']
    #Precio
    precio = oc['precioUnitario']

    #Producto ID
    #Para obtener la id de los productos hay que hacer getStock, que retorna una lista de productos
    lista_productos = stock_de_almacen(almacenId,sku)

    #No se de donde sacar la Direccion

    #Una vez que tengamos la info, hacer
    # 1) Mandar estos productos a la bodega de despacho con moverStock (Necesito: productoID y almacen de destino)
    # 2) Despacharlos con la funcion
    # 3) Avisar a gA que se hizo el despacho para terminar el ciclo

  end

  def transform_oc(oc)
    oc.delete("__v")
    oc.delete("fechaDespachos")
    oc.delete("precioUnitario")
    oc["idoc"] = oc.delete("_id")
    oc["fechaRecepcion"] = Time.new(oc.delete("created_at")).to_s
    oc["fechaEntrega"] = Time.new(oc.delete("fechaEntrega")).to_s

    return oc
  end

  #TODO: Corregir ids
  def getLinkGrupo(id) #Los IDS están malos, reemplazarlos por los correctos cuando los sepamos
    dic = {'571262b8a980ba030058ab4f'=>'1', '571262b8a980ba030058ab50'=>'2' , '571262b8a980ba030058ab51'=>'3' ,'571262b8a980ba030058ab52'=>'4' ,'571262b8a980ba030058ab53'=>'5' ,'571262b8a980ba030058ab54'=>'6' ,'571262b8a980ba030058ab55'=>'7' ,'???????????????????'=>'8',
            '??????????'=>'9','571262b8a980ba030058ab58'=>'10','571262b8a980ba030058ab59'=>'11','571262b8a980ba030058ab5a'=>'12'}
    url = "http://integra"+dic[id]+".ing.puc.cl/" #sprintf('http://integra%s.ing.puc.cl/', dic[id])
    return url
  end

  #TODO: Corregir ids y concatenación
  def getLinkGrupoSegunCuenta(idCuenta)
    dic = {'571262c3a980ba030058ab5b'=>'1', '571262c3a980ba030058ab5c'=>'2' , '3'=>'3' ,'4'=>'4',
      '571262c3a980ba030058ab61'=>'5' ,'6'=>'6' ,'571262c3a980ba030058ab60'=>'7' ,'8'=>'8',
            '9'=>'9','10'=>'10','11'=>'11','571262c3a980ba030068ab65'=>'12'}
    url = sprintf('http://integra%s.ing.puc.cl/', dic[idCuenta])
    return url
  end

  #TODO: Corregir ids y concatenación
  def getIdBanco(id) #TODO: Cambiar ID a los correctos
    dic = {'1'=>'571262c3a980ba030058ab5b', '2'=>'571262c3a980ba030058ab5c' , '3'=>'3' ,'4'=>'4',
      '5'=>'571262c3a980ba030058ab61' ,'6'=>'6' ,'7'=>'571262c3a980ba030058ab60' ,'8'=>'8',
            '9'=>'9','10'=>'10','11'=>'11','12'=>'571262c3a980ba030068ab65'}
    return dic[id]

   end

  #TODO: Corregir ids
  def getIdBancoSegunIdGrupo(id)
    dic = {'571262b8a980ba030058ab4f'=>'571262c3a980ba030058ab5b', '571262b8a980ba030058ab50'=>'571262c3a980ba030058ab5c' , '571262b8a980ba030058ab51'=>'571262c3a980ba030058ab5d' ,'571262b8a980ba030058ab52'=>'571262c3a980ba030058ab5f' ,'571262b8a980ba030058ab53'=>'571262c3a980ba030058ab61' ,'571262b8a980ba030058ab54'=>'571262c3a980ba030058ab62' ,'571262b8a980ba030058ab55'=>'571262c3a980ba030058ab60' ,'???????????????????'=>'8',
            '??????????'=>'9','571262b8a980ba030058ab58'=>'571262c3a980ba030058ab63','571262b8a980ba030058ab59'=>'571262c3a980ba030058ab64','571262b8a980ba030058ab5a'=>'571262c3a980ba030068ab65'}
    url = "http://integra"+dic[id]+".ing.puc.cl/" #sprintf('http://integra%s.ing.puc.cl/', dic[id])
    return url
  end

  def consultar_stock(sku)
    parsed_json = lista_de_almacenes()

    contador=0
    parsed_json.each do |almacen|
      contador += stock_de_almacen(almacen["_id"], sku).count() unless almacen["despacho"] # No consideramos el stock en el almacen de despacho
    end

    return contador
  end


  def obtener_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo OC--------------"
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.get(url+"obtener/"+idoc.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idoc.to_s)
              })
      json = JSON.parse(result.body)

      if json.count() > 1
        raise "Error4: se retornó más de una OC para el mismo id" and return
      elsif json.count() == 0
        raise "Error: No existe la OC pedida" and return
      end
      puts "--------OC Obtenida--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end


  def obtener_factura(idfactura)
    require 'httparty'
    url = "http://mare.ing.puc.cl/facturas/"
    result = HTTParty.get(url+idfactura.to_s,
            headers: {
              'Content-Type' => 'application/json',
              #'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idfactura.to_s)
              #TODO: Revisar si va o no la autorización
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una factura para el mismo id"
    end
    return json[0]
  end

  def obtener_transaccion(idtrx)
    require 'httparty'
    url = "http://mare.ing.puc.cl/banco/"
    result = HTTParty.get(url+idtrx.to_s,
            headers: {
              'Content-Type' => 'application/json',
              #'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idtrx.to_s)
              #TODO: Revisar si va o no la autorización
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una transacción para el mismo id"
    end
    return json[0]
  end


  # ------- funciones que utilizan otras funciones en este mismo documento ----

  def stock_de_almacen(almacenId, sku)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
    puts "--------Obteniendo Stock de Almacen--------------"
      url = "http://integracion-2016-dev.herokuapp.com/bodega/"
      result = HTTParty.get(url+"stock"+"?almacenId="+almacenId+"&"+"sku="+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)
              })
      json = JSON.parse(result.body)
      puts "--------Stock de Almacen Obtenido--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def lista_de_almacenes()
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Lista de Almacenes--------------"
      url = "http://integracion-2016-dev.herokuapp.com/bodega/"
      result = HTTParty.get(url+"almacenes",
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:z7gr473SiTMjSW8v+J6lqUwqIGo='
              })
      json = JSON.parse(result.body)
      puts "--------Lista de Almacenes Obtenida--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end
end
