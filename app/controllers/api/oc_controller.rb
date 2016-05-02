class Api::OcController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing
  skip_before_action :verify_authenticity_token

  def recibir
    idoc = params[:idoc]
    oc = obtener_oc(idoc) # Función definida en ApplicationController
    if oc["error"]
      render json: {"error": ex.message}, status: 503 and return
    end
    if consultar_stock(oc["sku"]) >= oc["cantidad"]
      aceptar_oc(oc["_id"])
      factura = generar_factura(idoc)
      json = enviarFactura(factura) #Definido un poco más abajo
      if json['validado']==false
        #TODO: Borrar la factura generada
        raise "ERROR: Factura fue rechazada por el comprador" and return
      end
      render json: {"aceptado": true, "idoc": oc["_id"]}

    else
      rechazar_oc(oc["_id"])
      render json: {"aceptado": false, "idoc": oc["_id"]}
    end
  end

  private

  def anular_factura(idFactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Anulando Factura--------------"
      url = "http://mare.ing.puc.cl/facturas/"
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
      url = "http://mare.ing.puc.cl/facturas/"
      result = HTTParty.put(url,
              body: {
                oc: idoc
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      puts "FORMATO FACTURA: "+ json.to_s
      localOc = Oc.find_by idoc: idoc
      #localOc.idFactura = json["_id"]
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
    idComprador = factura['comprador'] #Revisar sintaxis
    idFactura = factura['_id'] #Revisar sintaxis
    url = getLinkGrupo(idComprador)+'api/facturas/recibir/'+idFactura.to_s

    result = HTTParty.post(url,
            body: factura,
            headers: {
              'Content-Type' => 'application/json'
            })

    json = JSON.parse(result.body)
    puts "--------Factura Enviada, Respuesta Recibida--------------"
    return json

  end


  def aceptar_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Aceptando OC--------------"
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.post(url+"recepcionar/"+idoc.to_s,
              body:    {
                      id: idoc
                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      if json.count() > 1
        render json: {"error": "Error2: se retornó más de una OC para el mismo id"}, status: 503 and return
      elsif !json[0]["proveedor"]
        render json: {"error": "Error: No se pudo recibir la OC"}, status: 503 and return
      end
      puts "---------asd--------"+json.to_s #TODO: Borrar esta línea
      localOc = Oc.find_by idoc: idoc
      #localOc.estado = json[0]["aceptado"] #TODO: Verificar nombre estado
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
      url = "http://mare.ing.puc.cl/oc/"
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
      localOc = Oc.find_by id: idoc
      localOc.estado = json[0]["rechazado"] #TODO: Verificar nombre estado
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
    Net::SFTP.start('mare.ing.puc.cl', 'integra2', :password => 'fUgW9wJG') do |sftp|
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
