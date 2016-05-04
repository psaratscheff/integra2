class Api::OcController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing
  skip_before_action :verify_authenticity_token

  def recibir
    puts "------------------------Solicitud de recibir OC recibida----------------------------"
    idoc = params[:idoc]
    oc = obtener_oc(idoc) # Función definida en ApplicationController
    puts oc.to_s
    unless oc["cantidad"]
      puts "---------LA OC SOLICITADA NO EXISTE!-------"
      render json: {"error": "La OC solicitada no existe", msgCurso: oc}, status: 400 and return
    end
    if consultar_stock(oc["sku"]) >= oc["cantidad"]
      puts "--------Suficiente Stock--------------"
      aceptar_oc(oc["_id"])
      # Seguimos con el tema de la factura en un Thread aparte, para
      # no demorar la entrega de la respuesta
      #background do # Función background definida en ApplicationController
        proceder_con_factura(idoc)
      #end
      render json: {"aceptado": true, "idoc": oc["_id"]}
    else
      puts "--------Stock Insuficiente--------------"
      rechazar_oc(oc["_id"])
      render json: {"aceptado": false, "idoc": oc["_id"]}
    end
  end

  private

  def proceder_con_factura(idoc)
    factura = generar_factura(idoc)
    json = enviarFactura(factura) #Definido un poco más abajo
    # Si es que el key validado no existe en el json de la respuesta o el
    # value es false de ese key, la factura no fue validada
    if !json['validado'] || json['validado']==false
      puts "--------Factura NO Validada por Contraparte--------------"
      return false
      anular_factura(factura['_id'])
      #TODO: anular_oc() (O SI NO NOS QUITAN PUNTOS POR DEJAR OCS EN LA NADA!)
    else
      puts "--------Factura Validada por Contraparte--------------"
      return true
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
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Factura Anulada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def generar_factura(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Generando Factura--------------"
      url = getLinkServidorCurso + "facturas/"
      result = HTTParty.put(url,
              body: {
                oc: idoc
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      puts json.to_s
      # FORMATO FACTURA: {"__v"=>0, "created_at"=>"2016-05-02T14:57:30.324Z", "updated_at"=>"2016-05-02T14:57:30.324Z", "cliente"=>"571262b8a980ba030058ab50", "proveedor"=>"571262b8a980ba030058ab50", "bruto"=>6033, "iva"=>1147, "total"=>7180, "oc"=>"57276aaec1ff9b0300017d1b", "_id"=>"57276adac1ff9b0300017d1c", "estado"=>"pendiente"}
      localOc = Oc.find_by idoc: idoc
      localOc.idfactura = json["_id"]
      localOc.save!
      puts "--------Factura Generada--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def enviarFactura(factura)
    puts "--------Enviando Factura--------------"
    idCliente = factura['cliente'] #Revisar sintaxis
    idFactura = factura['_id'] #Revisar sintaxis
    url = getLinkGrupo(idCliente)+'api/facturas/recibir/'+idFactura.to_s
    puts "--------Enviando a: " + url + "-----"
    result = HTTParty.post(url,
            body: factura,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "Respuesta de la contraparte: " + result.to_s
    json = result.body
    puts "--------Factura Enviada, Respuesta Recibida--------------"
    return json
  end


  def aceptar_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Aceptando OC--------------"
      url = getLinkServidorCurso + "oc/"
      result = HTTParty.post(url+"recepcionar/"+idoc.to_s,
              body:    {
                      id: idoc
                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      puts "------Respuesta al recepcionar OC:---------"
      puts json.to_s
      if json.count() > 1
        puts "--------Error: se retornó más de una OC para el mismo id---------"
        render json: {"error": "Error2: se retornó más de una OC para el mismo id"}, status: 503 and return
      elsif !json[0]["proveedor"]
        puts "-----------------Error: No se pudo recibir la OC--------------------"
        render json: {"error": "Error: No se pudo recibir la OC"}, status: 503 and return
      end
      localOc = Oc.find_by idoc: idoc # Si es que la OC ya estaba en mi base de datos (La generé yo)
      if localOc == nil
        puts '-----Añadiendo OC a DB local------'
        localOc = Oc.new(transform_oc(json[0]))
      end
      localOc['estado'] = "aceptado"
      localOc.save!
      puts "--------OC Aceptada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def rechazar_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Rechazando OC--------------"
      url = getLinkServidorCurso + "oc/"
      result = HTTParty.post(url+"rechazar/"+idoc.to_s,
              body: {
                rechazo: 'No tenemos stock para el sku solicitado'
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)

      if json.count() > 1
        raise "Error3: se retornó más de una OC para el mismo id" and return
      end
      localOc = Oc.find_by idoc: idoc
      localOc['estado'] = "rechazado"
      localOc.save!
      puts "--------OC Rechazada--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
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
