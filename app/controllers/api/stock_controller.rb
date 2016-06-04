class Api::StockController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing

  def consultar
    puts "------------------------Solicitud de consultar STOCK recibida----------------------------"
    sku = params[:sku].to_i
    stock = consultar_stock(sku) # Función definida en ApplicationController
    retorno = { stock: stock, sku: sku.to_s}.to_json
    render json: retorno
  end

end
