class Api::StockController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing

  def consultar
    sku = params[:sku].to_i

    parsed_json = lista_de_almacenes()

    contador=0
    parsed_json.each do |almacen|
      contador += stock_de_almacen(almacen["_id"], sku).count()
    end

    retorno = { stock: contador, sku: sku.to_s}.to_json

    render json: retorno
  end

  private

  def stock_de_almacen(almacenId, sku)
    require 'httparty'
    url = "http://integracion-2016-dev.herokuapp.com/bodega/"
    result = HTTParty.get(url+"stock"+"?almacenId="+almacenId+"&"+"sku="+sku.to_s,
        headers: { 'Content-Type' => 'application/json',
                      'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)} )
    return JSON.parse(result.body)
  end

  def lista_de_almacenes()
    require 'httparty'
    url = "http://integracion-2016-dev.herokuapp.com/bodega/"
    result = HTTParty.get(url+"almacenes",
        headers: { 'Content-Type' => 'application/json',
                      'Authorization' => 'INTEGRACIONgrupo2:z7gr473SiTMjSW8v+J6lqUwqIGo='} )
    return JSON.parse(result.body)
  end

end

#result = HTTParty.post(url+"stock",
#    body: { almacenId: almacenId,
#            sku: sku.to_s}.to_json,
#    headers: { 'Content-Type' => 'application/json',
#                  'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)} )
