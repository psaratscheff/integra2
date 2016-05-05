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
      puts "--------Parámetros Incorrectos-------"
      render json: {"error": "Parámetros Incorrectos", "validado": false, "idtrx": idtrx.to_s}, status: 400 and return
    end
    puts "----idtrx: " + idtrx + "----idfactura: " + idfactura
    trx = obtener_transaccion(idtrx)
    factura = obtener_factura(idfactura)
    puts "trx: " + trx.to_s
    puts "factura: " + factura.to_s
    if !trx['monto']
      puts "-----TRX OBTENIDA INVÁLIDA!-----"
        render json: {"error": "TRX OBTENIDA INVÁLIDA!", "validado": false, "idtrx": idtrx.to_s}, status: 400 and return
    elsif (Oc.find_by idfactura: idfactura) == nil
      puts "-----No tenemos la factura pagada en nuestro sistema-----"
        render json: {"error": "No tenemos la factura en nuestro sistema", "validado": false, "idtrx": idtrx.to_s}, status: 400 and return
    elsif !factura['total']
      puts "-----FACTURA OBTENIDA INVÁLIDA!-----"
        render json: {"error": "FACTURA OBTENIDA INVÁLIDA!", "validado": false, "idtrx": idtrx.to_s}, status: 400 and return
    elsif factura['total'] != trx['monto']
      puts "------El pago no coincide con el monto de la factura-----"
        render json: {"error": "El pago no coincide con el monto de la factura", "validado": false, "idtrx": idtrx.to_s}, status: 400 and return
    end
    # Seguimos con el tema de la factura en un Thread aparte, para
    # no demorar la entrega de la respuesta
    #background do # Función background definida en ApplicationController
      localOc = Oc.find_by idfactura: idfactura
      localOc["estado"] = "pagada"
      localOc.save!
      #TODO: MARCAR FACTURA PAGADA EN EL SISTEMA DEL CURSO!!
      despachado = despachar(idfactura, factura) #Función definida en application_controller
      avisar_a_grupo(factura['cliente'], idfactura)
    #end
    render json: {"validado": true, "idtrx": idtrx.to_s}
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
      puts "(Avisar_a_Grupo)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Grupo Avisado de que el Proceso Terminó--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1008"
      render json: {"error": ex.message}, status: 503 and return
    end
    #TODO: Implementar: Agregar paso 10 AVSISAR QUE DESPACHAMOS
  end



end
