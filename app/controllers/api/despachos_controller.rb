class Api::DespachosController < ApplicationController
  def recibir
    puts "------------------------Aviso de DESPACHO recibido----------------------------"
    idfactura = params[:idfactura]
    localOc = Oc.find_by idfactura: idfactura
    localOc["estado"] = "despachada."
    localOc.save!
    puts "------------------------Aviso de DESPACHO marcado como recibido----------------------------"
    render json: {"validado": false}
  end
end
