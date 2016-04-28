class Api::OcController < ApplicationController
  include HmacHelper # Para utilizar la función de hashing
  skip_before_action :verify_authenticity_token

  def recibir
    idoc = params[:idoc].to_i

    oc = obtener_oc(idoc)

    render json: oc
  end

  private

  def obtener_oc(idoc)
    require 'httparty'
    url = "http://mare.ing.puc.cl/oc/"
    result = HTTParty.get(url+"obtener/"+idoc.to_s,
        headers: { 'Content-Type' => 'application/json',
                      'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idoc.to_s)} )
    puts result
    return JSON.parse(result.body)
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
