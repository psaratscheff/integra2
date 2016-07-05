class Api::StockController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing

  def consultar
    sku = params[:sku].to_i
    puts '<h1>------------------------Solicitud de consultar STOCK ' + sku.to_s + ' recibida----------------------------</h1>'
    if sku == 0
      retorno = { stock: 0, sku: sku.to_s }.to_json
    else
      stock = consultar_stock(sku) # Función definida en ApplicationController
      retorno = { stock: stock, sku: sku.to_s }.to_json
    end
    render json: retorno
  end

end
