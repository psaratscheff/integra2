class ScriptsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def test2t # (cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    comprar($groupid, $groupid, 2, 1, Time.now.tomorrow.to_i.to_s+"000", "OC generada por grupo 5")
  end
  def test2f # (cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    comprar($groupid, $groupid, 1, 1, Time.now.tomorrow.to_i.to_s+"000", "OC generada por grupo 5")
  end

  def test5 # (cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    comprar($groupid, "571262b8a980ba030058ab53", 50, 1, Time.now.tomorrow.to_i.to_s+"000", "OC generada por grupo 5")
  end

  def test8 # (cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    comprar($groupid, "572aac69bdb6d403005fb049", 18, 1, Time.now.tomorrow.to_i.to_s+"000", "OC generada por grupo 5")
  end

  def verstock
    require 'benchmark'
    benchmark = Benchmark.realtime {
      @sku1 = consultar_stock(1)
      @sku2 = consultar_stock(2)
      @sku3 = consultar_stock(3)
      @sku4 = consultar_stock(4)
      @sku5 = consultar_stock(5)
      @sku6 = consultar_stock(6)
      @sku7 = consultar_stock(7)
      @sku8 = consultar_stock(8)
      @sku9 = consultar_stock(9)
      @sku10 = consultar_stock(10)
      @sku11 = consultar_stock(11)
      @sku12 = consultar_stock(12)
      @sku13 = consultar_stock(13)
      @sku14 = consultar_stock(14)
      @sku15 = consultar_stock(15)
      @sku16 = consultar_stock(16)
      @sku17 = consultar_stock(17)
      @sku18 = consultar_stock(18)
      @sku19 = consultar_stock(19)
      @sku20 = consultar_stock(20)
      @sku21 = consultar_stock(21)
      @sku22 = consultar_stock(22)
      @sku23 = consultar_stock(23)
      @sku24 = consultar_stock(24)
      @sku25 = consultar_stock(25)
      @sku26 = consultar_stock(26)
      @sku27 = consultar_stock(27)
      @sku28 = consultar_stock(28)
      @sku29 = consultar_stock(29)
      @sku30 = consultar_stock(30)
      @sku31 = consultar_stock(31)
      @sku32 = consultar_stock(32)
      @sku33 = consultar_stock(33)
      @sku34 = consultar_stock(34)
      @sku35 = consultar_stock(35)
      @sku36 = consultar_stock(36)
      @sku37 = consultar_stock(37)
      @sku38 = consultar_stock(38)
      @sku39 = consultar_stock(39)
      @sku40 = consultar_stock(40)
      @sku41 = consultar_stock(41)
      @sku42 = consultar_stock(42)
      @sku43 = consultar_stock(43)
      @sku44 = consultar_stock(44)
      @sku45 = consultar_stock(45)
      @sku46 = consultar_stock(46)
      @sku47 = consultar_stock(47)
      @sku48 = consultar_stock(48)
      @sku49 = consultar_stock(49)
      @sku50 = consultar_stock(50)
      @sku51 = consultar_stock(51)
      @sku52 = consultar_stock(52)
      @sku53 = consultar_stock(53)
      @sku54 = consultar_stock(54)
      @sku55 = consultar_stock(55)
      @sku56 = consultar_stock(56)
    }
    @benchmark = benchmark * 1000
    render "verstock"
  end

  def comprar(cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    oc, localOc = generar_oc(cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    puts "OC GENERADA: " + oc.to_s

    respuesta = enviar_oc(oc)
    puts "WTF! : "+ respuesta['aceptado'].to_s
    if respuesta['aceptado']
      puts "------OC ACEPTADA: "+oc.to_s
      localOc.estado = "aceptada"
      localOc.save!
      render json: oc #TODO: Tengo demasiados renders de más :$
    else
      puts "------OC RECHAZADA: "+oc.to_s
      ocAnulada = anular_oc(oc)
      localOc.estado = "anulada por rechazo"
      localOc.save!
      render json: {anulada: true, oc: ocAnulada}.to_json #TODO: Tengo demasiados renders de más :$
    end
  end

  private


  def generar_oc(cliente, proveedor, sku, cantidad, fechaEntrega, notas)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Generando OC--------------"
      url = getLinkServidorCurso + "oc/"
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
      puts "(Generar_OC)Respuesta de la contraparte: " + result.body.to_s
      oc = JSON.parse(result.body)
      if !oc["proveedor"] # Validamos que la oc sea válida, probando si tiene el key proveedor
        render json: {"error": "Error: No se pudo recibir la OC"}, status: 503 and return
      end
      puts "--------OC Generada--------------"
      tOc = transform_oc(oc)
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1015"
      render json: {"error": ex.message}, status: 503 and return
    end
    localOc = Oc.new(tOc)
    localOc.save!

    return oc, localOc
  end

  def enviar_oc(oc)
    puts "--------Enviando OC--------------"
    idProveedor = oc['proveedor'] #Revisar sintaxis
    idOc = oc['_id']
    idOc = oc['idoc'] if (idOc == nil) # En caso de que oc no haya sido transformada todavía
    if getLinkGrupo(idProveedor) == nil # El grupo no está en nuestro diccionario
      puts "--------------ERROR: ID de grupo inválido--------"
      return {"aceptado" => false}
    end
    url = getLinkGrupo(idProveedor)+'api/oc/recibir/'+idOc.to_s
    puts "--------Enviando a: " + url + "-----"
    result = HTTParty.get(url,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)
    puts "(Enviar_OC)Respuesta de la contraparte: " + json.to_s
    puts "--------OC Enviada, Respuesta Recibida--------------"
    return json
  end

  def anular_oc(oc)
    puts "--------Anulando OC--------------"+oc.to_s
    idOc = oc['_id']
    idOc = oc['idoc'] if (idOc == nil) # En caso de que oc no haya sido transformada todavía
    url = getLinkServidorCurso + "oc/"
    result = HTTParty.delete(url + 'anular/' + idOc.to_s,
            body: {
              anulacion: "OC Rechazada por contraparte"
            }.to_json,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)
    puts "(Anular_OC)Respuesta de la contraparte: " + json.to_s
    puts "--------OC Anulada--------------"
    return json
  end

  #TODO: Borrar?? O sirve para algo??
  def analizar_sftp
    require 'net/sftp' # Utilizar requires dentro de la función que lo utiliza
    Net::SFTP.start(getLinkServidorCurso, 'integra2', :password => 'fUgW9wJG') do |sftp|
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
      puts "Realizando test..."
      url = getLinkServidorCurso + "oc/"
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
      localOc.estado = "aceptada"
      localOc.save!
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1016"
      render json: {"error": ex.message}, status: 503 and return
    end
  end
end
