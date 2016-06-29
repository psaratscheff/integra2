class Api::StockController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing

  def consultar
    sku = params[:sku].to_i
    puts '<h1>------------------------Solicitud de consultar STOCK ' + sku.to_s + ' recibida----------------------------</h1>'
    stock = consultar_stock(sku) # Función definida en ApplicationController
    retorno = { stock: stock, sku: sku.to_s }.to_json
    render json: retorno
  end

end
