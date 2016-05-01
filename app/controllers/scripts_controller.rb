class ScriptsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def generar_oc
    require 'httparty'
    cliente = "571262b8a980ba030058ab50" # Mi grupo: 571262b8a980ba030058ab50
    proveedor = "571262b8a980ba030058ab50"
    cantidad = 10
    sku = 2
    precio = Item.find(sku).Precio_Unitario # Definido en seeds.rb
    notas = ""
    # El tiempo de mañana (Un día después de ahora), convertido a int (epoch)
    # y luego convertido a string y agregado los 000 por los milisegundos.
    fechaEntrega = Time.now.tomorrow.to_i.to_s+"000"
    begin # Intentamos realizar conexión externa y obtener OC
    url = "http://mare.ing.puc.cl/oc/"
    result = HTTParty.put(url+"crear",
        body:    {
                    cliente: cliente,
                    proveedor: proveedor,
                    sku: sku,
                    fechaEntrega: fechaEntrega,
                    precioUnitario: precio,
                    cantidad: cantidad,
                    canal: "b2b"
                  }.to_json,
        headers: {
          'Content-Type' => 'application/json'
        })

    oc = JSON.parse(result.body)
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}
    end
    oc.delete("__v")
    #oc[:id] = oc.delete :__v

    #Item.new(oc)

    render json: oc
    #return JSON.parse(result.body)
  end

end
