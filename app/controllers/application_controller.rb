class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def consultar_stock(sku)
    parsed_json = lista_de_almacenes()

    contador=0
    parsed_json.each do |almacen|
      contador += stock_de_almacen(almacen["_id"], sku).count()
    end

    return contador
  end

  def obtener_oc(idoc)
    require 'httparty'
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
  end


  # ------- funciones que utilizan otras funciones en este mismo documento ----

  def stock_de_almacen(almacenId, sku)
    require 'httparty'
    url = "http://integracion-2016-dev.herokuapp.com/bodega/"
    result = HTTParty.get(url+"stock"+"?almacenId="+almacenId+"&"+"sku="+sku.to_s,
            headers: {
              'Content-Type' => 'application/json',
              'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)
            })
    return JSON.parse(result.body)
  end

  def lista_de_almacenes()
    require 'httparty'
    url = "http://integracion-2016-dev.herokuapp.com/bodega/"
    result = HTTParty.get(url+"almacenes",
            headers: {
              'Content-Type' => 'application/json',
              'Authorization' => 'INTEGRACIONgrupo2:z7gr473SiTMjSW8v+J6lqUwqIGo='
            })
    return JSON.parse(result.body)
  end
end
