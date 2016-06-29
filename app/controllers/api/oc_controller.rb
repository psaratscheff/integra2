class Api::OcController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing
  skip_before_action :verify_authenticity_token

  def recibir
    puts "------------------------Solicitud de recibir OC recibida----------------------------"
    idoc = params[:idoc]
    oc = obtener_oc(idoc) # Función definida en ApplicationController
    puts oc.to_s
    puts "Pasare esto"
    unless oc["cantidad"]
      puts "---------LA OC SOLICITADA NO EXISTE!-------"
      render json: {error: "La OC solicitada no existe", aceptado: false, idoc: idoc, msgCurso: oc}, status: 400 and return
    end
    if consultar_stock(oc["sku"]) >= oc["cantidad"]
      puts "--------Suficiente Stock--------------"
      aceptar_oc(oc["_id"])
      # Seguimos con el tema de la factura en un Thread aparte, para
      # no demorar la entrega de la respuesta
      background do # Función background definida en ApplicationController
        proceder_con_factura(idoc)
      end
      render json: {aceptado: true, idoc: oc["_id"]}
    else
      puts "--------Stock Insuficiente--------------"
      rechazar_oc(oc["_id"])
      render json: {aceptado: false, idoc: oc["_id"]}
    end
  end

  private

  def proceder_con_factura(idoc)
    factura = generar_factura(idoc)
    if !factura
      return false
    end
    json = enviarFactura(factura) # Definido un poco más abajo
    # Si es que el key validado no existe en el json de la respuesta o el
    # value es false de ese key, la factura no fue validada
    if !json['validado'] || json['validado']==false
      puts "--------Factura NO Validada por Contraparte--------------"
      return false
      #TODO: anular_factura(factura['_id'])
      #TODO: anular_oc() (O SI NO NOS QUITAN PUNTOS POR DEJAR OCS EN LA NADA!)
    else
      puts "--------Factura Validada por Contraparte--------------"
      oc = Oc.find_by idoc: idoc
      if oc.nil?
        puts "-----------ERROOOOR: Muy bizarro :/ La OC no existe y eso que la acabo de generar ---------"
        render json: { error: "ERROOOOR: Muy bizarro :/ La OC no existe y eso que la acabo de generar" }, status: 500 and return false
      else
        puts "--------Factura Aceptada---------"
        oc.estado = "Facturada"
        oc.save!
        return true
      end
    end
  end

  def anular_factura(idFactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Anulando Factura--------------"
      url = getLinkServidorCurso + "facturas/"
      result = HTTParty.post(url+"cancel",
              body: {
                id: idFactura,
                motivo: "Factura fue cancelada por contraparte"
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      puts "(Anular_Factura)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Factura Anulada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1004: " + ex.message
      render json: { error: ex.message }, status: 503 and return false
    end
  end

  def enviarFactura(factura)
    puts "--------Enviando Factura--------------"
    idCliente = factura['cliente'] #Revisar sintaxis
    idFactura = factura['_id'] #Revisar sintaxis
    url = getLinkGrupo(idCliente)+'api/facturas/recibir/'+idFactura.to_s
    puts "--------Enviando a: " + url + "-----"
    result = HTTParty.get(url,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "(Enviar_Factura)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)
    puts "--------Factura Enviada--------------"
    return json
  end




  # -------------------Funciones de prueba--------------------------

  def sftp
    require 'net/sftp' # Utilizar requires dentro de la función que lo utiliza
    Net::SFTP.start(getLinkServidorCurso, 'integra2', :password => 'fUgW9wJG') do |sftp|
      # download a file or directory from the remote host
      #sftp.download!("/pedidos", "public/pedidos", :recursive => true)
      # list the entries in a directory
      sftp.dir.foreach("/pedidos") do |entry|
        if entry.name[0]!="."
          puts "/pedidos/"+entry.name
          data = sftp.download!("/pedidos/"+entry.name)
          id = three_letters = data[/<id>(.*?)<\/id>/m, 1]
          sku = three_letters = data[/<sku>(.*?)<\/sku>/m, 1]
          qty = three_letters = data[/<qty>(.*?)<\/qty>/m, 1]
          puts "ID: "+id+" // sku: "+ sku + " // qty: "+qty
        end
      end
    end
    render nothing: true
  end

  def hmactest
    a = encode("GET")
    puts a
    render nothing: true
  end

end
