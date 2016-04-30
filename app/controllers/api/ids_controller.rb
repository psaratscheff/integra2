class Api::IdsController < ApplicationController
  def grupo
    id = {"id": "571262b8a980ba030058ab50"}
    render json: id
  end

  def banco
    id = {"id": "571262c3a980ba030058ab5c"}
    render json: id
  end

  def almacenId
    parsed_json = lista_de_almacenes() # Función definida en ApplicationController
    almId = nil # Necesario declararlo fuera del loop
    parsed_json.each do |almacen|
      almId = almacen["_id"] if almacen["recepcion"] # TODO: y si tenemos más de una bodega de recepcion??
    end
    id = {"id": almId}
    render json: id
  end
end
