class Api::PagosController < ApplicationController
  def index
  	render json: {"aceptado": false, "idoc": 123}
  end

  def recibir #TODO: Probar que funcione
  	#Parte 7 del flujo: (recibir idtrx e idfactura)
  	idtrx = params[:idtrx]
    idfactura = params[:idfactura]
    if !idfactura || !idtrx
      render json: {validado: false, idtrx: idtrx.to_s} and return
    end
    trx = obtener_transaccion(idtrx)
    factura = obtener_factura(idfactura)
    if !trx['monto'] || (Oc.find_by idfactura: idfactura) == nil || factura['monto'] != trx['monto']
      render json: {validado: false, idtrx: idtrx.to_s} and return
    end
    render json: {validado: true, idtrx: idtrx.to_s}

    #TODO: EN UN NUEVO THREAD!!
    despachado = despachar(idfactura) #Función definida en application_controller
    avisar_a_grupo(grupo)
    #TODO: Agregar paso 10 AVSISAR QUE DESPACHAMOS
  end
end
