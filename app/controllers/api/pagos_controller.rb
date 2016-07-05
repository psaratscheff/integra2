class Api::PagosController < ApplicationController
  def index
  	render json: {aceptado: false, idoc: 123}
  end

  def recibir
    puts "<h1>------------------------Solicitud de recibir PAGO recibida----------------------------</h1>"
  	#Parte 7 del flujo: (recibir idtrx e idfactura)
  	idtrx = params[:idtrx]
    idfactura = params[:idfactura]
    if !idfactura || !idtrx
      puts "--------Parámetros Incorrectos-------"
      render json: {error: "Parámetros Incorrectos", validado: false, idtrx: idtrx.to_s}, status: 400 and return
    end
    puts "----idtrx: " + idtrx + "----idfactura: " + idfactura
    trx = obtener_transaccion(idtrx)
    factura = obtener_factura(idfactura)
    puts "trx: " + trx.to_s
    puts "factura: " + factura.to_s
    if !trx['monto']
      puts "-----TRX OBTENIDA INVÁLIDA!-----"
        render json: {error: "TRX OBTENIDA INVÁLIDA!", validado: false, idtrx: idtrx.to_s}, status: 400 and return
    elsif (Oc.find_by idfactura: idfactura) == nil
      puts "-----No tenemos la factura pagada en nuestro sistema-----"
        render json: {error: "No tenemos la factura en nuestro sistema", validado: false, idtrx: idtrx.to_s}, status: 400 and return
    elsif !factura['total']
      puts "-----FACTURA OBTENIDA INVÁLIDA!-----"
        render json: {error: "FACTURA OBTENIDA INVÁLIDA!", validado: false, idtrx: idtrx.to_s}, status: 400 and return
    elsif factura['total'] != trx['monto']
      puts "------El pago no coincide con el monto de la factura-----"
        render json: {error: "El pago no coincide con el monto de la factura", validado: false, idtrx: idtrx.to_s}, status: 400 and return
    end
    # Seguimos con el tema de la factura en un Thread aparte, para
    # no demorar la entrega de la respuesta
    background do # Función background definida en ApplicationController
      localOc = Oc.find_by idfactura: idfactura
      localOc["estado"] = "pagada"
      localOc.save!
      #TODO: MARCAR FACTURA PAGADA EN EL SISTEMA DEL CURSO!!
      despachado = despachar(idfactura, factura) #Función definida en application_controller
      avisar_a_grupo(factura['cliente'], idfactura)
    end
    render json: { validado: true, idtrx: idtrx.to_s }
  end

  def recibir_sin_validar_trx
    puts "<h1>------------------------Solicitud de recibir PAGO recibida----------------------------</h1>"
  	#Parte 7 del flujo: (recibir idtrx e idfactura)
    idfactura = params[:idfactura]
    if !idfactura
      puts "--------Parámetros Incorrectos-------"
      render json: {error: "Parámetros Incorrectos", validado: false}, status: 400 and return
    end
    puts "---a---idfactura: " + idfactura
    factura = obtener_factura(idfactura)
    puts "factura: " + factura.to_s
    if (Oc.find_by idfactura: idfactura) == nil
      puts "-----No tenemos la factura pagada en nuestro sistema-----"
        render json: {error: "No tenemos la factura en nuestro sistema", validado: false}, status: 400 and return
    elsif !factura['total']
      puts "-----FACTURA OBTENIDA INVÁLIDA!-----"
        render json: {error: "FACTURA OBTENIDA INVÁLIDA!", validado: false}, status: 400 and return
    end
    # Seguimos con el tema de la factura en un Thread aparte, para
    # no demorar la entrega de la respuesta
    background do # Función background definida en ApplicationController
      localOc = Oc.find_by idfactura: idfactura
      localOc["estado"] = "pagada"
      localOc.save!
      #TODO: MARCAR FACTURA PAGADA EN EL SISTEMA DEL CURSO!!
      despachado = despachar(idfactura, factura) #Función definida en application_controller
      avisar_a_grupo(factura['cliente'], idfactura)
    end
    render json: { validado: true }
  end

  private

  def avisar_a_grupo(groupid, idfactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Avisando a Grupo que el Proceso Terminó--------------"
      url = getLinkServidorGrupo(get_grupo_by_id(groupid)) + "api/despachos/recibir/" + idfactura
      puts "--------Enviando aviso a: " + url.to_s
      result = HTTParty.get(url+idfactura,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Avisar_a_Grupo)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Grupo Avisado de que el Proceso Terminó--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1008: " + ex.message
      render json: { error: ex.message }, status: 503 and return
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
    items_despachados = 0
    puts '------PAGOS_DESPACHAR: Qty: ' + qty.to_s + ' Sku: ' + sku.to_s + ' idoc: ' + idoc.to_s + '------------'
    almacenes.each do |almacen|
      next if almacen['despacho']
      while items_despachados < qty
        productos = stock_de_almacen(almacen['_id'], sku)
        break if productos.count == 0
        productos.each do |producto|
          puts '--- Despachando item N°' + (items_despachados + 1).to_s + '/' + qty.to_s + ' idoc: ' + idoc.to_s + '-----'
          idProducto = producto['_id']
          mover_a_despacho(idProducto) #TODO: IMPLEMENTAR FUNCION
          despachar_producto(producto, almacenClienteId, idoc, precio) #TODO: IMPLEMENTAR FUNCION
          items_despachados += 1
          if items_despachados >= qty
            oc["estado"] = "despachada"
            oc.save!
            return true
          end
        end
      end
    end
  end

  def mover_a_despacho(idProducto)
    require 'httparty'
    idDespacho = $despachoid

    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Moviendo Producto a Despacho PAGOS--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
      result = HTTParty.post(url+"moveStock",
              body: {
                productoId: idProducto,
                almacenId: idDespacho
              }.to_json,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('POST'+idProducto+idDespacho)
              })
      puts "(Mover_a_Despacho PAGOS)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      producto =Producto.find_by(_id: idProducto)
      producto.almacen = Almacen.find_by(_id: idDespacho) if producto != nil
      puts "--------Producto Movido a Despacho PAGOS--------------"
      sleep(5) # Sleep 5 seconds...
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1009pagos1009: " + ex.message
      render json: { error: ex.message }, status: 503 and return
    end
  end

=begin # ESTE METODO ESTA EN APP_CONTROLLER, pq duplicado?!?!?! ESTE MALO!!!
  def despachar_producto(producto, almacenClienteId, idoc, precio)
    require 'httparty'
    idProducto = producto['_id']

    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Despachando Producto a Cliente B2B--------------"
      url = "http://integracion-2016-prod.herokuapp.com/bodega/"
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
      puts "(Despachar_Producto)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      producto = Producto.find_by(_id: idProducto)
      producto.delete if producto != nil
      puts "--------Producto Despachado a Cliente B2B--------------"
      sleep(5) # Sleep 5 seconds...
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1010a: " + ex.message
      render json: { error: ex.message }, status: 503 and return
    end
  end
=end

end
