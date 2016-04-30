class Api::FacturasController < ApplicationController
  skip_before_action :verify_authenticity_token

  def recibir
    idfactura = params[:idfactura]
    factura = obtener_factura(idfactura) # Función definida en ApplicationController
   	transferencia = transferir(factura)[0] #TODO: Manejar cuando la transferencia retorna error.
   	enviarTransferencia(transferencia)
  end

  def transferir(factura) #Retorna la transacción o el error

  	montoFactura = factura['monto'] #TODO: Revisar sintaxis
    idCuentaOrigen = getIdBanco('2')
    grupoVendedor = factura['proveedor'] #TODO: Revisar sintaxis. No sabemos como nos pasan el numero de grupo
    idCuentaDestino = getIdBanco(grupoVendedor)

    require 'httparty'
    url = "http://mare.ing.puc.cl/banco/trx/"
    result = HTTParty.put(url,
            body: {
              monto: montoFactura, #TODO: Validar formatos
              origen: idCuentaOrigen,
              destino: idCuentaDestino, 
            }.to_json,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)

    if json.count() > 1
      raise "Error: se retornó más de una transacción"
  	end
    return json[0]
  end

  def enviarTransferencia(transaccion)

  	idTransaccion = transaccion['_id'].to_s #TODO: Revisar sintaxis
  	url = getLinkGrupoSegunCuenta+'api/pagos/recibir/'+idTransaccion

    result = HTTParty.post(url,
            body: transaccion,
            headers: {
              'Content-Type' => 'application/json'
            })
    json = JSON.parse(result.body)
    return json
  end

end



