class Api::DespachosController < ApplicationController
  def recibir
    render json: {validado: false}
  end
end
