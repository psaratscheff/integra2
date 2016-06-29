class Api::DespachosController < ApplicationController
  def recibir
    puts "<h1>------------------------Aviso de DESPACHO recibido----------------------------</h1>"
    idfactura = params[:idfactura]
    background do
      sleep 5
      localOc = Oc.find_by idfactura: idfactura
      localOc["estado"] = "despachada."
      localOc.save!
      puts "------------------------AvDESPACHO marcado como recibido----------------------------"
    end
    render json: {"validado": false}
  end
end
