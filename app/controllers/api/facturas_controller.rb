class Api::FacturasController < ApplicationController
  skip_before_action :verify_authenticity_token

  def recibir
    puts "------------------------Solicitud de recibir FACTURA recibida----------------------------"
    idFactura = params[:idfactura]
    factura = obtener_factura(idFactura)
    if !!factura && validar_factura(idFactura, factura) # Comparando con nuestra base de datos
      # Seguimos con el tema de la factura en un Thread aparte, para
      # no demorar la entrega de la respuesta
      background do # Función background definida en ApplicationController
        continuar_con_pago(idFactura, factura)
      end
      render json: {"validado": true, "idfactura": idFactura}
    else
      # IMPORTANTE: Ya se hizo el rendering en validar_factura (Es complejo, depende de cosas)
    end
  end

  private

  def continuar_con_pago(idFactura, factura)
    trx = pagar_factura(factura)
    if trx != false && trx['monto'] != nil
      puts "-------FACTURA YA PAGADA!!------"
      localOc = Oc.find_by idfactura: idFactura
      localOc["estado"] = "pagada"
      localOc.save!
      puts "-------LocalOc actualizada------"
      grupoVendedor = get_grupo_by_id(factura['proveedor'])
      enviarTransferencia(trx, idFactura, grupoVendedor)
      puts "-------Transferencia Enviada a Grupo------"
    else
      puts "-----ERROR! --- No se pudo completar la transacción :("
      #TODO: No se, avisarles que no se completo la transacción?
    end
  end

  def pagar_factura(factura)
    require 'httparty'
  	montoFactura = factura['total']
    idCuentaOrigen = getIdBanco('2')
    idVendedor = factura['proveedor']
    grupoVendedor = get_grupo_by_id(idVendedor)
    idCuentaDestino = getIdBanco(grupoVendedor)
    puts "----- factura: " + factura.to_s
    begin
      puts "--------Pagando Factura--------------"
      url = getLinkServidorCurso + "banco/trx/"
      result = HTTParty.put(url,
              body: {
                monto: montoFactura.to_i,
                origen: idCuentaOrigen,
                destino: idCuentaDestino,
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Pagar_Factura)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Factura Pagada--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1001: " + ex.message
      render json: { error: ex.message }, status: 503 and return false
    end
  end

  def enviarTransferencia(transaccion, idFactura, grupoDestinatario)
  	idTransaccion = transaccion['_id'].to_s
  	url = getLinkServidorGrupo(grupoDestinatario) + 'api/pagos/recibir/' + idTransaccion + '?' + 'idfactura=' + idFactura
    puts "--------Enviando Transferencia--------------"
    puts "------ trx: " + transaccion.to_s
    puts "------ url(trx): " + url
    result = HTTParty.get(url,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "(Enviar_Trx)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)
    puts "--------Transferencia Enviada--------------"
    return json
  end

  def marcar_factura_pagada(idFactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Marcando Factura Pagada--------------"
      url = getLinkServidorCurso + "facturas/"
      result = HTTParty.post(url+"pay",
              body: {
                id: idFactura,
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Marcar_Factura_Pagada)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Factura Marcada Pagada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1002: " + ex.message
      render json: { error: ex.message }, status: 503 and return false
    end
  end

  def validar_factura(idFactura, factura)
    oc = Oc.find_by idoc: factura['oc']
    if factura == nil
      puts "--------Factura NO Existe---------"
      render json: {"error": "Factura Rechazada, no existe en el sistema del curso", "validado": false, "idfactura": idFactura}, status: 400 and return false # 400 = Bad Request, error del cliente
    elsif factura['cliente'].to_s != $groupid # Variable global con nuestro GroupId en AppCtrlr
      puts "--------Factura RECHAZADA---------! No soy el cliente de la factura"
      render json: {"error": "Factura Rechazada, la factura no existe o no soy el proveedor de la factura", "validado": false, "idfactura": idFactura}, status: 400 and return false # 400 = Bad Request, error del cliente
    elsif oc == nil
      puts "--------Factura RECHAZADA---------! No tengo la Oc en mi base de datos (Mi empresa no la generó)"
      render json: {"error": "Factura Rechazada, no tengo la OC en mi base de datos (Mi empresa no la generó)", "validado": false, "idfactura": idFactura}, status: 400 and return false
    else
      puts "--------Factura Aceptada---------"
      oc['estado'] = "Facturada"
      oc['idfactura'] = idFactura
      oc.save!
      return true
    end
  end

  def obtener_factura(idFactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Factura--------------"
      url = getLinkServidorCurso + "facturas/"
      result = HTTParty.get(url+idFactura,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Obtener_Factura)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Factura Obtenida--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1003: " + ex.message
      render json: { error: ex.message }, status: 503 and return false
    end
  end

end
