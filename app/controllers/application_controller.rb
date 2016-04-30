class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private


  def getLinkGrupo(id) #TODO: Cambiar ID a los correctos
    dic = {'571262b8a980ba030058ab4f'=>'1', '571262b8a980ba030058ab50'=>'2' , '3'=>'3' ,'4'=>'4' ,'571262b8a980ba030058ab53'=>'5' ,'6'=>'6' ,'571262b8a980ba030058ab55'=>'7' ,'9ifds'=>'8',
            'dw12e'=>'9','43few4'=>'10','12d43'=>'11','571262b8a980ba030058ab5a'=>'12'}
    url = sprintf('http://integra%s.ing.puc.cl/', dic[id])
    return url
   end

  def getLinkGrupoSegunCuenta(idCuenta)
    dic = {'571262c3a980ba030058ab5b'=>'1', '571262c3a980ba030058ab5c'=>'2' , '3'=>'3' ,'4'=>'4' 
          ,'571262c3a980ba030058ab61'=>'5' ,'6'=>'6' ,'571262c3a980ba030058ab60'=>'7' ,'8'=>'8',
            '9'=>'9','10'=>'10','11'=>'11','571262c3a980ba030068ab65'=>'12'}
    url = sprintf('http://integra%s.ing.puc.cl/', dic[idCuenta])
    return url
  end

  def getIdBanco(id) #TODO: Cambiar ID a los correctos
    dic = {'1'=>'571262c3a980ba030058ab5b', '2'=>'571262c3a980ba030058ab5c' , '3'=>'3' ,'4'=>'4' 
          ,'5'=>'571262c3a980ba030058ab61' ,'6'=>'6' ,'7'=>'571262c3a980ba030058ab60' ,'8'=>'8',
            '9'=>'9','10'=>'10','11'=>'11','12'=>'571262c3a980ba030068ab65'}
    return dic[id]

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
    url = "http://mare.ing.puc.cl/oc/"
    result = HTTParty.get(url+"obtener/"+idoc.to_s,
            headers: {
              'Content-Type' => 'application/json',
              #'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idoc.to_s)
              #TODO: Revisar si va o no la autorización
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una OC para el mismo id"
    end
    return json[0]
  end


  def obtener_factura(idfactura)
    require 'httparty'
    url = "http://mare.ing.puc.cl/oc/"
    result = HTTParty.get(url+idfactura.to_s,
            headers: {
              'Content-Type' => 'application/json',
              #'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idfactura.to_s)
              #TODO: Revisar si va o no la autorización
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una factura para el mismo id"
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
