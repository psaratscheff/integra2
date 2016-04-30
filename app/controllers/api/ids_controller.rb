class Api::IdsController < ApplicationController
  def grupo
    id = {"id": "571262b8a980ba030058ab50"}
    render json: id
  end

  def banco
    id = {"id": "571262c3a980ba030058ab5c"}
    render json: id
  end
end
