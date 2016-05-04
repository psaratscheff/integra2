class Api::DespachosController < ApplicationController
  def recibir
    puts "------------------------Aviso de DESPACHO recibido----------------------------"
    render json: {"validado": false}
  end
end
