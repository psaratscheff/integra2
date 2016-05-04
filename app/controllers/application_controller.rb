class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include HmacHelper # Para utilizar la función de hashing

  $groupid = "571262b8a980ba030058ab50"
  $bancoid = "571262c3a980ba030058ab5c"

  private

  #Esta función es para ejecutar código en background, paralelo al http request
  def background(&block)
    puts "-------------Iniciando Nuevo THREAD------------------"
    # Genero un nuevo Thread (Proceso aparte del original e independiente)
    Thread.new do
      # Con yield le digo que ejecute el código del bloque aquí dentro
      yield
      # Luego cierro la conexión a la database que un Thread nuevo siempre abre
      ActiveRecord::Base.connection.close
    end
    puts "-------------Nuevo THREAD Finalizado------------------"
  end

  # --------------------------------------------------------------------------
  # ------------------------------Links---------------------------------------
  # --------------------------------------------------------------------------

  def getLinkServidorCurso()
    return "http://mare.ing.puc.cl/"
  end

  def getLinkServidorGrupo(numeroGrupo)
    # Habilitar esta línea para hacer pruebas locales
    # return "http://localhost:3000/"
    # Habilitar esta línea para deployment
    return "http://integra" + numeroGrupo + ".ing.puc.cl/"
  end

  # --------------------------------------------------------------------------
  # ------------------------------IDs-----------------------------------------
  # --------------------------------------------------------------------------

  def getIdGrupo2()
    return "571262b8a980ba030058ab50"
  end

  def getBancoGrupo2()
    return "571262c3a980ba030058ab5c"
  end

  def getRecepcionId()
    parsed_json = lista_de_almacenes() # Función definida en ApplicationController
    almId = nil # Necesario declararlo fuera del loop
    parsed_json.each do |almacen|
      almId = almacen["_id"] if almacen["recepcion"] # TODO: y si tenemos más de una bodega de recepcion??
    end
    return almId
  end

  def getIdDespacho
    #TODO: MEJORAR ESTE SISTEMA
    return "571262aaa980ba030058a14f"
  end

  #TODO: Corregir ids
  def getLinkGrupo(id) #Los IDS están malos, reemplazarlos por los correctos cuando los sepamos
    grupo = get_grupo_by_id(id)
    url = getLinkServidorGrupo(grupo)
    return url
  end

  def get_grupo_by_id(id)
          # ID del grupo => Número del Grupo
    dic = {'571262b8a980ba030058ab4f'=>'1',
          '571262b8a980ba030058ab50'=>'2',
          '571262b8a980ba030058ab51'=>'3',
          '571262b8a980ba030058ab52'=>'4',
          '571262b8a980ba030058ab53'=>'5',
          '571262b8a980ba030058ab54'=>'6',
          '571262b8a980ba030058ab55'=>'7',
          '571262b8a980ba030058ab56'=>'8',
          '571262b8a980ba030058ab57'=>'9',
          '571262b8a980ba030058ab58'=>'10',
          '571262b8a980ba030058ab59'=>'11',
          '571262b8a980ba030058ab5a'=>'12'}
    return dic[id]
  end

  #TODO: Corregir ids y concatenación
  def getLinkGrupoSegunCuenta(idCuenta)
          # Cuenta del Grupo => Número del Grupo
    dic = {'571262c3a980ba030058ab5b'=>'1',
          '571262c3a980ba030058ab5c'=>'2',
          '571262c3a980ba030058ab5d'=>'3',
          '571262c3a980ba030058ab5f'=>'4',
          '571262c3a980ba030058ab61'=>'5',
          '571262c3a980ba030058ab62'=>'6',
          '571262c3a980ba030058ab60'=>'7',
          '571262c3a980ba030058ab5e'=>'8',
          '571262c3a980ba030068ab66'=>'9',
          '571262c3a980ba030058ab63'=>'10',
          '571262c3a980ba030058ab64'=>'11',
          '571262c3a980ba030068ab65'=>'12'}
    url = getLinkServidorGrupo(dic[idCuenta])
    return url
  end

  #TODO: Corregir ids
  def getIdBanco(grupo) #TODO: Cambiar ID a los correctos
          # Número del Grupo => Cuenta del Grupo
    dic = {'1'=>'571262c3a980ba030058ab5b',
          '2'=>'571262c3a980ba030058ab5c',
          '3'=>'571262c3a980ba030058ab5d',
          '4'=>'571262c3a980ba030058ab5f',
          '5'=>'571262c3a980ba030058ab61',
          '6'=>'571262c3a980ba030058ab62',
          '7'=>'571262c3a980ba030058ab60',
          '8'=>'571262c3a980ba030058ab5e',
          '9'=>'571262c3a980ba030068ab66',
          '10'=>'571262c3a980ba030058ab63',
          '11'=>'571262c3a980ba030058ab64',
          '12'=>'571262c3a980ba030068ab65'}
    return dic[grupo]
   end

   #TODO: Corregir ids
   def get_almacen_id(grupo) #TODO: Cambiar ID a los correctos
           # Número del Grupo => Almacen De Recepcion del Grupo
     dic = {'1'=>'571262aaa980ba030058a147',
            '2'=>'571262aaa980ba030058a14e',
            '3'=>'3',
            '4'=>'571262aaa980ba030058a240',
            '5'=>'5',
            '6'=>'6',
            '7'=>'7',
            '8'=>'571262aaa980ba030058a31e',
            '9'=>'9',
            '10'=>'571262aaa980ba030058a40c',
            '11'=>'571262aaa980ba030058a488',
            '12'=>'12'}
     return dic[grupo]
    end

  #TODO: Corregir ids
  def getIdBancoSegunIdGrupo(id)
          # ID del Grupo => Cuenta del Grupo
    dic = {'571262b8a980ba030058ab4f'=>'571262c3a980ba030058ab5b',
          '571262b8a980ba030058ab50'=>'571262c3a980ba030058ab5c',
          '571262b8a980ba030058ab51'=>'571262c3a980ba030058ab5d',
          '571262b8a980ba030058ab52'=>'571262c3a980ba030058ab5f',
          '571262b8a980ba030058ab53'=>'571262c3a980ba030058ab61',
          '571262b8a980ba030058ab54'=>'571262c3a980ba030058ab62',
          '571262b8a980ba030058ab55'=>'571262c3a980ba030058ab60',
          '???????????????????'=>'8',
          '??????????'=>'9',
          '571262b8a980ba030058ab58'=>'571262c3a980ba030058ab63',
          '571262b8a980ba030058ab59'=>'571262c3a980ba030058ab64',
          '571262b8a980ba030058ab5a'=>'571262c3a980ba030068ab65'}
    url = getLinkServidorGrupo(dic[id])
    return url
  end

  # ----------------------------------------------------------------------------
  # -----------------------------------OCs--------------------------------------
  # ----------------------------------------------------------------------------

  def obtener_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo OC--------------"
      url = getLinkServidorCurso + "oc/"
      result = HTTParty.get(url+"obtener/"+idoc.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idoc.to_s)
              })
      puts "(Obtener_OC)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)

      if json.count() > 1
        raise "Error4: se retornó más de una OC para el mismo id" and return
      elsif json.count() == 0
        raise "Error: No existe la OC pedida" and return
      end
      puts "--------OC Obtenida--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1012"
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def transform_oc(oc)
    oc.delete("__v")
    oc.delete("fechaDespachos")
    oc.delete("precioUnitario")
    oc.delete("updated_at") if oc["updated_at"]
    oc.delete("notas") if oc["notas"]
    oc["idoc"] = oc.delete("_id")
    created_at = oc.delete("created_at")
    fechaEntrega = oc.delete("fechaEntrega")
    puts "Created_at: " + created_at
    puts "fechaEntrega: " + fechaEntrega
    oc["fechaRecepcion"] = created_at.to_s
    oc["fechaEntrega"] = fechaEntrega.to_s
    return oc
  end

  #-----------------------------------------------------------------------------
  # -------------------------------Facturas-------------------------------------
  # ----------------------------------------------------------------------------

  def obtener_factura(idfactura)
    require 'httparty'
    puts "--------Obteniendo Factura--------------"
    url = getLinkServidorCurso + "facturas/"
    result = HTTParty.get(url+idfactura.to_s,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "(Obtener_Factura)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una factura para el mismo id"
    end
    puts "--------Factura Obtenida--------------"
    return json[0]
  end

  #-----------------------------------------------------------------------------
  # ------------------------------Transacción-----------------------------------
  # ----------------------------------------------------------------------------

  def obtener_transaccion(idtrx)
    require 'httparty'
    puts "--------Obteniendo Transacción--------------"
    url = getLinkServidorCurso + "banco/"
    result = HTTParty.get(url++'trx/' + idtrx.to_s,
            headers: {
              'Content-Type' => 'application/json'
            })
    puts "(Obtener_Trx)Respuesta de la contraparte: " + result.body.to_s
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una transacción para el mismo id"
    end
    puts "--------Transacción Obtenida--------------"
    return json[0]
  end

  # ----------------------------------------------------------------------------
  # ------------------------------Almacen---------------------------------------
  # ----------------------------------------------------------------------------

    def consultar_stock(sku)
      parsed_json = lista_de_almacenes()

      contador=0
      parsed_json.each do |almacen|
        contador += stock_de_almacen(almacen["_id"], sku).count() unless almacen["despacho"] # No consideramos el stock en el almacen de despacho
      end

      return contador
    end

  def stock_de_almacen(almacenId, sku)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
    puts "--------Obteniendo Stock de Almacen--------------"
      url = "http://integracion-2016-dev.herokuapp.com/bodega/"
      result = HTTParty.get(url+"stock"+"?almacenId="+almacenId+"&"+"sku="+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)
              })
      puts "(Stock_de_Almacen)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Stock de Almacen Obtenido--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1013"
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def lista_de_almacenes()
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Lista de Almacenes--------------"
      url = "http://integracion-2016-dev.herokuapp.com/bodega/"
      result = HTTParty.get(url+"almacenes",
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:z7gr473SiTMjSW8v+J6lqUwqIGo='
              })
      puts "(Lista_de_Almacenes)Respuesta de la contraparte: " + result.body.to_s
      json = JSON.parse(result.body)
      puts "--------Lista de Almacenes Obtenida--------------"
      return json
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      puts "error 1014"
      render json: {"error": ex.message}, status: 503 and return
    end
  end
end
