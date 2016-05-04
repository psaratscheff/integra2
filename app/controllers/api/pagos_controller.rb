class Api::PagosController < ApplicationController
  def index
  	render json: {"aceptado": false, "idoc": 123}
  end

  def recibir
    puts "------------------------Solicitud de recibir PAGO recibida----------------------------"
  	#Parte 7 del flujo: (recibir idtrx e idfactura)
  	idtrx = params[:idtrx]
    idfactura = params[:idfactura]
    if !idfactura || !idtrx
      render json: {validado: false, idtrx: idtrx.to_s}, status: 400 and return
    end
    trx = obtener_transaccion(idtrx)
    factura = obtener_factura(idfactura)
    puts "trx: " + trx.to_s
    puts "factura: " + factura.to_s
    if !trx['monto']
      puts "-----TRX OBTENIDA INVÁLIDA!-----"
        render json: {validado: false, idtrx: idtrx.to_s}, status: 400 and return
    elsif (Oc.find_by idfactura: idfactura) == nil
      puts "-----No tenemos la factura pagada en nuestro sistema-----"
        render json: {validado: false, idtrx: idtrx.to_s}, status: 400 and return
    elsif !factura['total']
      puts "-----FACTURA OBTENIDA INVÁLIDA!-----"
        render json: {validado: false, idtrx: idtrx.to_s}, status: 400 and return
    elsif factura['total'] != trx['monto']
      puts "------El pago no coincide con el monto de la factura-----"
        render json: {validado: false, idtrx: idtrx.to_s}, status: 400 and return
    end
    # Seguimos con el tema de la factura en un Thread aparte, para
    # no demorar la entrega de la respuesta
    #background do # Función background definida en ApplicationController
      localOc = Oc.find_by idfactura: idfactura
      localOc["estado"] = "pagada"
      localOc.save!
      despachado = despachar(idfactura, factura) #Función definida en application_controller
      avisar_a_grupo(factura['cliente'], idfactura)
    #end
    render json: {validado: true, idtrx: idtrx.to_s}
  end

  private

  def avisar_a_grupo(grupo, idfactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Avisando a Grupo que el Proceso Terminó--------------"
      url = getLinkServidorGrupo(grupo) + "api/despachos/recibir/"
      result = HTTParty.get(url+idfactura,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Grupo Avisado de que el Proceso Terminó--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
    #TODO: Implementar: Agregar paso 10 AVSISAR QUE DESPACHAMOS
  end

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
        return if itemsDespachados == qty
        productos = get_array_productos_almacen(almacen['_id'], sku)
        productos.each do |producto|
          return if itemsDespachados == qty
          mover_a_despacho(producto) #TODO: IMPLEMENTAR FUNCION
          despachar_producto(producto, almacenClienteId, idoc, precio) #TODO: IMPLEMENTAR FUNCION
          itemsDespachados += 1
        end
      end
    end
    oc["estado"] = "despachada"
    oc.save!
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
                almacenId: almacenClienteId,
                oc: idoc,
                precio: precio.to_i
              }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('POST'+idProducto+almacenClienteId)
              })
      json = JSON.parse(result.body)
      puts "--------Producto Despachado a Cliente B2B--------------"
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
      result = HTTParty.get(url+"stock"+"?"+"almacenId="+almacenid+"&"+'sku='+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenid+sku.to_s)
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
