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
      puts "--------Suficiente Stock--------------"
      aceptar_oc(oc["_id"])
      factura = generar_factura(idoc)
      json = enviarFactura(factura) #Definido un poco más abajo
      # Si es que el key validado no existe en el json de la respuesta o el
      # value es false de ese key, la factura no fue validada
      if !json['validado'] || json['validado']==false
        puts "--------Factura NO Validada por Contraparte--------------"
        puts "Factura inválida: " + factura.to_s
        anular_factura(factura['_id'])
        raise "ERROR: Factura fue rechazada por el cliente" and return
      else
        puts "--------Factura Validada por Contraparte--------------"
        render json: {"aceptado": true, "idoc": oc["_id"]}
      end
    else
      puts "--------Stock Insuficiente--------------"
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
