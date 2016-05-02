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
      oc = transform_oc(oc)
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
    localOc = Oc.new(oc)
    localOc.save!

    render json: oc
  end

  def test
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      url = "http://mare.ing.puc.cl/oc/"
      result = HTTParty.post(url+"recepcionar/"+"57275b33c1ff9b0300017cf1",
          body:    {
                      id: "57275b33c1ff9b0300017cf1"
                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      puts json.to_s
      if json.count() > 1
        raise "Error2: se retornó más de una OC para el mismo id" and return
      end
      localOc = Oc.find_by id: "57275b33c1ff9b0300017cf1"
      localOc.estado = json[0]["aceptado"] #TODO: Verificar nombre estado
      localOc.save!
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

end
