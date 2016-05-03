class Api::IdsController < ApplicationController
  def grupo
    id = {"id": getIdGrupo2()}
    render json: id
  end

  def banco
    id = {"id": getBancoGrupo2()}
    render json: id
  end

  def almacenId
    almId = getRecepcionId()
    id = {"id": almId}
    render json: id
  end
end
