class AlmacensController < ApplicationController
  before_action :set_almacen, only: [:show, :edit, :update, :destroy]

  # GET /almacens
  # GET /almacens.json
  def index
    @almacens = Almacen.all
  end

  # GET /almacens/1
  # GET /almacens/1.json
  def show
  end

  # GET /almacens/new
  def new
    @almacen = Almacen.new
  end

  # GET /almacens/1/edit
  def edit
  end

  # POST /almacens
  # POST /almacens.json
  def create
    @almacen = Almacen.new(almacen_params)

    respond_to do |format|
      if @almacen.save
        format.html { redirect_to @almacen, notice: 'Almacen was successfully created.' }
        format.json { render :show, status: :created, location: @almacen }
      else
        format.html { render :new }
        format.json { render json: @almacen.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /almacens/1
  # PATCH/PUT /almacens/1.json
  def update
    respond_to do |format|
      if @almacen.update(almacen_params)
        format.html { redirect_to @almacen, notice: 'Almacen was successfully updated.' }
        format.json { render :show, status: :ok, location: @almacen }
      else
        format.html { render :edit }
        format.json { render json: @almacen.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /almacens/1
  # DELETE /almacens/1.json
  def destroy
    @almacen.destroy
    respond_to do |format|
      format.html { redirect_to almacens_url, notice: 'Almacen was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_almacen
    @almacen = Almacen.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def almacen_params
    params.require(:almacen).permit(:pulmon, :despacho, :recepcion, :espacioTotal, :espacioUtilizado, :_id)
  end
end
