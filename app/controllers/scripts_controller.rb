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
    # El tiempo de mañana (Un día después de ahora), convertido a int (epoch)
    # y luego convertido a string y agregado los 000 por los milisegundos.
    fechaEntrega = Time.now.tomorrow.to_i.to_s+"000"

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
