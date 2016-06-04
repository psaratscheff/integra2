class Api::DespachosController < ApplicationController
  def recibir
    puts "------------------------Aviso de DESPACHO recibido----------------------------"
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
