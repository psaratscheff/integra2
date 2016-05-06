class Api::IdsController < ApplicationController
  def grupo
    puts "------------------------Solicitud de ID GRUPO recibida----------------------------"
    id = {"id": $groupid} # Variable global con nuestro GroupId en AppCtrlr
    render json: id
  end

  def banco
    puts "------------------------Solicitud de ID BANCO recibida----------------------------"
    id = {"id": $bancoid} # Variable global con nuestro BancoId en AppCtrlr
    render json: id
  end

  def almacenId
    puts "------------------------Solicitud de ID ALMACEN_ID recibida----------------------------"
    almId = $recepcionid # Variable global con nuestro BancoId en AppCtrlr
    id = {"id": almId}
    render json: id
  end
end
