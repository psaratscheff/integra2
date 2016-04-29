class Api::OcController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing
  skip_before_action :verify_authenticity_token

  def recibir
    idoc = params[:idoc]
    puts idoc
    oc = obtener_oc(idoc) # Función definida en ApplicationController

    if consultar_stock(oc["sku"]) >= oc["cantidad"]
      #TODO: Procesar orden
      aceptar_oc(oc["_id"])
      render json: {"aceptado": true}
    else
      rechazar_oc(oc["_id"])
      render json: {"aceptado": false}
    end
  end

  private

  def aceptar_oc(idoc)
    require 'httparty'
    url = "http://mare.ing.puc.cl/oc/"
    result = HTTParty.post(url+"recepcionar/"+idoc.to_s,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una OC para el mismo id"
    end
    return json[0]
  end

  def rechazar_oc(idoc)
    require 'httparty'
    url = "http://mare.ing.puc.cl/oc/"
    result = HTTParty.post(url+"rechazar/"+idoc.to_s,
            body: {
              rechazo: 'No tenemos stock para el sku solicitado'
            }.to_json,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una OC para el mismo id"
    end
    return json[0]
  end

  def sftp
    require 'net/sftp' # Utilizar requires dentro de la función que lo utiliza
    Net::SFTP.start('mare.ing.puc.cl', 'integra2', :password => 'fUgW9wJG') do |sftp|
      # download a file or directory from the remote host
      #sftp.download!("/pedidos", "public/pedidos", :recursive => true)
      # list the entries in a directory
      sftp.dir.foreach("/pedidos") do |entry|
        if entry.name[0]!="."
          puts "/pedidos/"+entry.name
          data = sftp.download!("/pedidos/"+entry.name)
          id = three_letters = data[/<id>(.*?)<\/id>/m, 1]
          sku = three_letters = data[/<sku>(.*?)<\/sku>/m, 1]
          qty = three_letters = data[/<qty>(.*?)<\/qty>/m, 1]
          puts "ID: "+id+" // sku: "+ sku + " // qty: "+qty
        end
      end
    end
    render nothing: true
  end

  def hmactest
    a = encode("GET")
    puts a
    render nothing: true
  end

end
