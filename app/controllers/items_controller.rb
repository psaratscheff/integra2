class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  # GET /items
  # GET /items.json
  def index
    @items = Item.all
    if request.headers["Content-Type"] == "application/json"
      render json: @items # Devuelvo el json si me lo piden como json (API)
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
  if request.headers["Content-Type"] == "application/json"
    render json: @item # Devuelvo el json si me lo piden como json (API)
  end
  end

  # Eliminamos los otros métodos, solo queremos mostrar la información

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:Sku, :Descripcion, :Tipo, :Grupo, :Unidades, :Costo_Unitario, :Lote, :Tiempo_Medio, :Precio_Unitario, :Sku1, :Sku2, :Sku3, :Sku4)
    end
end
