class ScriptsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def generar_oc
    require 'httparty'

    cliente = "g5"
    proveedor = "g2"
    cantidad = 10
    sku = 1
    precio = 1000
    notas = ""
    fechaEntrega = "1461980200000"

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

    render json: JSON.parse(result.body)
    #return JSON.parse(result.body)
  end

end
