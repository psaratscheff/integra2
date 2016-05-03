class Api::PagosController < ApplicationController
  def index
  	render json: {"aceptado": false, "idoc": 123}
  end

  def recibir #TODO: Probar que funcione
  	#Parte 7 del flujo: (recibir idtrx e idfactura)
  	idtrx = params[:idtrx]
    idfactura = params[:idfactura] #TODO: Revisar si estamos entregando bien el parametro.

  	#Parte 8 del fujo: (confirmar trx)
  	require 'httparty'
    begin # Intentamos realizar conexión externa y obtener la transacción
      puts "--------Obteniendo Transacción--------------"
      url = "http://mare.ing.puc.cl/banco/"
      result = HTTParty.get(url+idtrx,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      puts "--------Transacción Obtenida--------------"
      #Parte 9 del fujo: (despachar)

      despachar(idtrx,idfactura) #Función definida en application_controller

      render json: {validado: true, idtrx: idtrx.to_s}
      return = { validado: true, idtrx: idtrx.to_s}.to_json

    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"Transacción no encontrada": ex.message}, status: 503 and return
    end
  end


end
