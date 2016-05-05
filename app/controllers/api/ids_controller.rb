class Api::IdsController < ApplicationController
  def grupo
    puts "------------------------Solicitud de ID GRUPO recibida----------------------------"
    id = {"id": getIdGrupo2()}
    render json: id
  end

  def banco
    puts "------------------------Solicitud de ID BANCO recibida----------------------------"
    id = {"id": getBancoGrupo2()}
    render json: id
  end

  def almacenId
    puts "------------------------Solicitud de ID ALMACEN_ID recibida----------------------------"
    almId = getRecepcionId()
    id = {"id": almId}
    render json: id
  end
end
