class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include HmacHelper # Para utilizar la función de hashing

  $groupid = "571262b8a980ba030058ab50"
  $bancoid = "571262c3a980ba030058ab5c"

  private

  # --------------------------------------------------------------------------
  # ------------------------------Links---------------------------------------
  # --------------------------------------------------------------------------

  def getLinkServidorCurso()
    return "http://mare.ing.puc.cl/"
  end

  def getLinkServidorGrupo(numero)
    return "http://integra" + grupo + ".ing.puc.cl/"
  end

  # --------------------------------------------------------------------------
  # ------------------------------IDs-----------------------------------------
  # --------------------------------------------------------------------------

  def getIdGrupo2()
    return "571262b8a980ba030058ab50"
  end

  def getBancoGrupo2()
    return "571262c3a980ba030058ab5c"
  end

  def getRecepcionId()
    parsed_json = lista_de_almacenes() # Función definida en ApplicationController
    almId = nil # Necesario declararlo fuera del loop
    parsed_json.each do |almacen|
      almId = almacen["_id"] if almacen["recepcion"] # TODO: y si tenemos más de una bodega de recepcion??
    end
    return almId
  end

  def getIdDespacho
    #TODO: MEJORAR ESTE SISTEMA
    return "571262aaa980ba030058a14f"
  end

  #TODO: Corregir ids
  def getLinkGrupo(id) #Los IDS están malos, reemplazarlos por los correctos cuando los sepamos
    grupo = get_grupo_by_id(id)
    url = getLinkServidorGrupo(grupo)
    return url
  end

  def get_grupo_by_id(id)
    dic = {'571262b8a980ba030058ab4f'=>'1', '571262b8a980ba030058ab50'=>'2' , '571262b8a980ba030058ab51'=>'3' ,'571262b8a980ba030058ab52'=>'4' ,'571262b8a980ba030058ab53'=>'5' ,'571262b8a980ba030058ab54'=>'6' ,'571262b8a980ba030058ab55'=>'7' ,'???????????????????'=>'8',
            '??????????'=>'9','571262b8a980ba030058ab58'=>'10','571262b8a980ba030058ab59'=>'11','571262b8a980ba030058ab5a'=>'12'}
    return dic[id]
  end

  #TODO: Corregir ids y concatenación
  def getLinkGrupoSegunCuenta(idCuenta)
    dic = {'571262c3a980ba030058ab5b'=>'1', '571262c3a980ba030058ab5c'=>'2' , '3'=>'3' ,'4'=>'4',
      '571262c3a980ba030058ab61'=>'5' ,'6'=>'6' ,'571262c3a980ba030058ab60'=>'7' ,'8'=>'8',
            '9'=>'9','10'=>'10','11'=>'11','571262c3a980ba030068ab65'=>'12'}
    url = getLinkServidorGrupo(dic[idCuenta])
    return url
  end

  #TODO: Corregir ids
  def getIdBanco(grupo) #TODO: Cambiar ID a los correctos
    dic = {'1'=>'571262c3a980ba030058ab5b', '2'=>'571262c3a980ba030058ab5c' , '3'=>'3' ,'4'=>'4',
      '5'=>'571262c3a980ba030058ab61' ,'6'=>'6' ,'7'=>'571262c3a980ba030058ab60' ,'8'=>'8',
            '9'=>'9','10'=>'10','11'=>'11','12'=>'571262c3a980ba030068ab65'}
    return dic[grupo]
   end

   #TODO: Corregir ids
   def get_almacen_id(grupo) #TODO: Cambiar ID a los correctos
     dic = {'1'=>'571262c3a980ba030058ab5b', '2'=>'571262aaa980ba030058a14e' , '3'=>'3' ,'4'=>'4',
       '5'=>'571262c3a980ba030058ab61' ,'6'=>'6' ,'7'=>'571262c3a980ba030058ab60' ,'8'=>'8',
             '9'=>'9','10'=>'10','11'=>'11','12'=>'571262c3a980ba030068ab65'}
     return dic[grupo]
    end

  #TODO: Corregir ids
  def getIdBancoSegunIdGrupo(id)
    dic = {'571262b8a980ba030058ab4f'=>'571262c3a980ba030058ab5b', '571262b8a980ba030058ab50'=>'571262c3a980ba030058ab5c' , '571262b8a980ba030058ab51'=>'571262c3a980ba030058ab5d' ,'571262b8a980ba030058ab52'=>'571262c3a980ba030058ab5f' ,'571262b8a980ba030058ab53'=>'571262c3a980ba030058ab61' ,'571262b8a980ba030058ab54'=>'571262c3a980ba030058ab62' ,'571262b8a980ba030058ab55'=>'571262c3a980ba030058ab60' ,'???????????????????'=>'8',
            '??????????'=>'9','571262b8a980ba030058ab58'=>'571262c3a980ba030058ab63','571262b8a980ba030058ab59'=>'571262c3a980ba030058ab64','571262b8a980ba030058ab5a'=>'571262c3a980ba030068ab65'}
    url = getLinkServidorGrupo(dic[id])
    return url
  end

  # ----------------------------------------------------------------------------
  # -----------------------------------OCs--------------------------------------
  # ----------------------------------------------------------------------------

  def obtener_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo OC--------------"
      url = getLinkServidorCurso + "oc/"
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

  def transform_oc(oc)
    oc.delete("__v")
    oc.delete("fechaDespachos")
    oc.delete("precioUnitario")
    oc["idoc"] = oc.delete("_id")
    oc["fechaRecepcion"] = Time.new(oc.delete("created_at")).to_s
    oc["fechaEntrega"] = Time.new(oc.delete("fechaEntrega")).to_s

    return oc
  end

  #-----------------------------------------------------------------------------
  # -------------------------------Facturas-------------------------------------
  # ----------------------------------------------------------------------------

  def obtener_factura(idfactura)
    require 'httparty'
    puts "--------Obteniendo Factura--------------"
    url = getLinkServidorCurso + "facturas/"
    result = HTTParty.get(url+idfactura.to_s,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una factura para el mismo id"
    end
    puts "--------Factura Obtenida--------------"
    return json[0]
  end

  #-----------------------------------------------------------------------------
  # ------------------------------Transacción-----------------------------------
  # ----------------------------------------------------------------------------

  def obtener_transaccion(idtrx)
    require 'httparty'
    puts "--------Obteniendo Transacción--------------"
    url = getLinkServidorCurso + "banco/"
    result = HTTParty.get(url++'trx/' + idtrx.to_s,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una transacción para el mismo id"
    end
    puts "--------Transacción Obtenida--------------"
    return json[0]
  end

  # ----------------------------------------------------------------------------
  # ------------------------------Almacen---------------------------------------
  # ----------------------------------------------------------------------------

    def despachar(idfactura, factura) #TODO: Revisar si este método va aquí
      oc = Oc.find_by idfactura: idfactura
      sku = oc['sku']
      qty = oc['cantidad']
      precio = Item.find(sku).Precio_Unitario
      idoc = oc['idoc']
      grupo = get_grupo_by_id(factura['cliente'])
      almacenClienteId = get_almacen_id(grupo)

      almacenes = lista_de_almacenes()
      itemsDespachados = 0
      almacenes.each do |almacen|
        unless almacen['despacho']
          return if contador == qty
          productos = get_array_productos_almacen(almacen['_id'], sku)
          productos.each do |producto|
            return if contador == qty
            mover_a_despacho(producto) #TODO: IMPLEMENTAR FUNCION
            despachar_producto(producto, almacenClienteId, idoc, precio) #TODO: IMPLEMENTAR FUNCION
          end
        end
      end

      return true
    end

    def mover_a_despacho(producto)
      require 'httparty'
      idDespacho = getIdDespacho()
      idProducto = producto['_id']

      begin # Intentamos realizar conexión externa y obtener OC
        puts "--------Moviendo Producto a Despacho--------------"
        url = "http://integracion-2016-dev.herokuapp.com/bodega/"
        result = HTTParty.post(url+"moveStock",
                body: {
                  productoId: idProducto,
                  almacenId: idDespacho
                }.to_json,
                headers: {
                  'Content-Type' => 'application/json',
                  'Authorization' => 'INTEGRACIONgrupo2:'+encode('POST'+idProducto+idDespacho)
                })
        json = JSON.parse(result.body)
        puts "--------Producto Movido a Despacho--------------"
        return json
      rescue => ex # En caso de excepción retornamos error
        logger.error ex.message
        render json: {"error": ex.message}, status: 503 and return
      end
    end

    def despachar_producto(producto, almacenClienteId, idoc, precio)
      require 'httparty'
      idProducto = producto['_id']

      begin # Intentamos realizar conexión externa y obtener OC
        puts "--------Despachando Producto a Cliente B2B--------------"
        url = "http://integracion-2016-dev.herokuapp.com/bodega/"
        result = HTTParty.post(url+"moveStockBodega",
                body: {
                  productoId: idProducto,
                  almacenId: idDespacho,
                  oc: idoc,
                  precio: precio.to_i
                }.to_json,
                headers: {
                  'Content-Type' => 'application/json',
                  'Authorization' => 'INTEGRACIONgrupo2:'+encode('POST'+idProducto+idDespacho)
                })
        json = JSON.parse(result.body)
        puts "--------Producto Despachado a Cliente B2B--------------"
        return json
      rescue => ex # En caso de excepción retornamos error
        logger.error ex.message
        render json: {"error": ex.message}, status: 503 and return
      end
    end

    def consultar_stock(sku)
      parsed_json = lista_de_almacenes()

      contador=0
      parsed_json.each do |almacen|
        contador += stock_de_almacen(almacen["_id"], sku).count() unless almacen["despacho"] # No consideramos el stock en el almacen de despacho
      end

      return contador
    end

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

  def get_array_productos_almacen(almacenid, sku)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Productos por SKU del Almacen--------------"
      url = "http://integracion-2016-dev.herokuapp.com/bodega/"
      result = HTTParty.get(url+"stock"+"?"+"almacenId="+almacenid+"&"+'sku='+sku,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)
              })
      json = JSON.parse(result.body)
      puts "--------Productos Obtenidos por SKU del Almacen--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end

  end
end
