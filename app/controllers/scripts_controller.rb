class ScriptsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def analizar_sftp
    require 'net/sftp' # Utilizar requires dentro de la función que lo utiliza
    Net::SFTP.start('mare.ing.puc.cl', 'integra2', :password => 'fUgW9wJG') do |sftp|
      # download a file or directory from the remote host
      #sftp.download!("/pedidos", "public/pedidos", :recursive => true)
      # list the entries in a directory
      sftp.dir.foreach("/pedidos") do |entry|
        if entry.name[0]!="."
          data = sftp.download!("/pedidos/"+entry.name)
          id = three_letters = data[/<id>(.*?)<\/id>/m, 1]
          sku = three_letters = data[/<sku>(.*?)<\/sku>/m, 1]
          qty = three_letters = data[/<qty>(.*?)<\/qty>/m, 1]
          puts "ID: "+id+" // sku: "+ sku + " // qty: "+qty

        end
      end
    end
    render json: {"Proceso terminado exitosamente?": true}
  end

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
