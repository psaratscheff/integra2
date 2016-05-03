class ScriptsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def probar_compra
    cliente = "571262b8a980ba030058ab50" # Mi grupo: 571262b8a980ba030058ab50
    proveedor = "571262b8a980ba030058ab50"
    cantidad = 10
    sku = 2
    notas = ""
    # El tiempo de mañana (Un día después de ahora), convertido a int (epoch)
    # y luego convertido a string y agregado los 000 por los milisegundos.
    fechaEntrega = Time.now.tomorrow.to_i.to_s+"000"
    comprar(cliente, proveedor, sku, cantidad, fechaEntrega, notas)
  end

  def comprar(cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    oc = generar_oc(cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    puts "OC GENERADA: " + oc.to_s
    respuesta = enviar_oc(oc)
    if respuesta['aceptado']
      # Wuhu! La aceptaron!!
      # Nada que hacer, estamos listos! :)
      render json: oc #TODO: Tengo demasiados renders de más :$
    else
      # Buuuu pesaos q&% :(
      # Debemos anular la OC
      ocAnulada = anular_oc(oc)
      render json: {anulada: true, oc: ocAnulada}.to_json #TODO: Tengo demasiados renders de más :$
    end
  end
  def generar_oc(cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Generando OC--------------"
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.put(url+"crear",
          body:    {
                      cliente: cliente,
                      proveedor: proveedor,
                      sku: sku,
                      fechaEntrega: fechaEntrega,
                      precioUnitario: Item.find(sku).Precio_Unitario, # Definido en seeds.rb
                      cantidad: cantidad,
                      canal: "b2b"
                    }.to_json,
          headers: {
            'Content-Type' => 'application/json'
          })

      oc = JSON.parse(result.body)
      if !oc["proveedor"] # Validamos que la oc sea válida, probando si tiene el key proveedor
        render json: {"error": "Error: No se pudo recibir la OC"}, status: 503 and return
      end
      puts "--------OC Generada--------------"
      oc = transform_oc(oc)
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
    localOc = Oc.new(oc)
    localOc.save!

    return oc
  end

  def enviar_oc(oc)
    puts "--------Enviando OC--------------"
    idProveedor = oc['proveedor'] #Revisar sintaxis
    idOc = oc['_id']
    idOc = oc['idoc'] if (idOc == nil) # En caso de que oc no haya sido transformada todavía
    url = getLinkGrupo(idProveedor)+'api/oc/recibir/'+idOc.to_s
    puts "--------Enviando a: " + url + "-----"
    result = HTTParty.get(url,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "Respuesta de la contraparte: " + result.to_s
    json = result.body
    puts "--------OC Enviada, Respuesta Recibida--------------"
    return json
  end

  def anular_oc(oc)
    puts "--------Anulando OC--------------"+oc.to_s
    idOc = oc['_id']
    idOc = oc['idoc'] if (idOc == nil) # En caso de que oc no haya sido transformada todavía
    url = "http://mare.ing.puc.cl/oc/"
    result = HTTParty.delete(url + 'anular/' + idOc.to_s,
            body: {
              anulacion: "OC Rechazada por contraparte"
            }.to_json,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = result.body
    puts "--------OC Anulada--------------"
    return json
  end

  #TODO: Borrar?? O sirve para algo??
  def analizar_sftp
    require 'net/sftp' # Utilizar requires dentro de la función que lo utiliza
    Net::SFTP.start('mare.ing.puc.cl', 'integra2', :password => 'fUgW9wJG') do |sftp|
      # download a file or directory from the remote host
      #sftp.download!("/pedidos", "public/pedidos", :recursive => true)
      # list the entries in a directory
      sftp.dir.foreach("/pedidos") do |entry|
        if entry.name[0]!="."
          data = sftp.download!("/pedidos/"+entry.name)
          id = three_letters = data[/<id>(.*?)<\/id>/m, 1]
          sku = three_letters = data[/<sku>(.*?)<\/sku>/m, 1]
          qty = three_letters = data[/<qty>(.*?)<\/qty>/m, 1]
          puts "ID: "+id+" // sku: "+ sku + " // qty: "+qty
        end
      end
    end
    render json: {"Proceso terminado exitosamente?": true}
  end

  #TODO: Borrar?? O sirve para algo??
  def test
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.post(url+"recepcionar/"+"57275b33c1ff9b0300017cf1",
          body:    {
                      id: "57275b33c1ff9b0300017cf1"
                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      puts json.to_s
      if json.count() > 1
        raise "Error2: se retornó más de una OC para el mismo id" and return
      end
      localOc = Oc.find_by id: "57275b33c1ff9b0300017cf1"
      localOc.estado = json[0]["aceptado"] #TODO: Verificar nombre estado
      localOc.save!
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

end
