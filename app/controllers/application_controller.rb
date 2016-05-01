class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def transform_oc(oc)
    oc.delete("__v")
    oc.delete("fechaDespachos")
    oc.delete("precioUnitario")
    oc["idoc"] = oc.delete("_id")
    oc["fechaRecepcion"] = Time.new(oc.delete("created_at")).to_s
    oc["fechaEntrega"] = Time.new(oc.delete("fechaEntrega")).to_s

    return oc
  end

  def getLinkGrupo(id) #Los IDS están malos, reemplazarlos por los correctos cuando los sepamos
    dic = {'abc123'=>'1', '12dweads'=>'2' , 'sd213d3'=>'3' ,'12w21w'=>'4' ,'asdf3'=>'5' ,'2134redsd'=>'6' ,'43fqw'=>'7' ,'9ifds'=>'8',
            'dw12e'=>'9','43few4'=>'10','12d43'=>'11','234fsdf'=>'12'}
    url = sprintf('http://integra%s.ing.puc.cl/', dic[id])
   end


  def consultar_stock(sku)
    parsed_json = lista_de_almacenes()

    contador=0
    parsed_json.each do |almacen|
      contador += stock_de_almacen(almacen["_id"], sku).count() unless almacen["despacho"] # No consideramos el stock en el almacen de despacho
    end

    return contador
  end

  def obtener_oc(idoc)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.get(url+"obtener/"+idoc.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idoc.to_s)
              })
      json = JSON.parse(result.body)

      if json.count() > 1
        raise "Error: se retornó más de una OC para el mismo id"
      end
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end


  # ------- funciones que utilizan otras funciones en este mismo documento ----

  def stock_de_almacen(almacenId, sku)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      url = "http://integracion-2016-dev.herokuapp.com/bodega/"
      result = HTTParty.get(url+"stock"+"?almacenId="+almacenId+"&"+"sku="+sku.to_s,
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)
              })
      return JSON.parse(result.body)
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

  def lista_de_almacenes()
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      url = "http://integracion-2016-dev.herokuapp.com/bodega/"
      result = HTTParty.get(url+"almacenes",
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => 'INTEGRACIONgrupo2:z7gr473SiTMjSW8v+J6lqUwqIGo='
              })
      return JSON.parse(result.body)
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end
end
