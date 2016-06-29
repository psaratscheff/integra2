class Api::IdsController < ApplicationController
  def grupo
    puts "<h1>------------------------Solicitud de ID GRUPO recibida----------------------------</h1>"
    id = {"id": $groupid} # Variable global con nuestro GroupId en AppCtrlr
    render json: id
  end

  def banco
    puts "<h1>------------------------Solicitud de ID BANCO recibida----------------------------</h1>"
    id = {"id": $bancoid} # Variable global con nuestro BancoId en AppCtrlr
    render json: id
  end

  def almacenId
    puts "<h1>------------------------Solicitud de ID ALMACEN_ID recibida----------------------------</h1>"
    almId = $recepcionid # Variable global con nuestro RecepcionId en AppCtrlr
    id = {"id": almId}
    render json: id
  end
end
