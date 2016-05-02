class Api::FacturasController < ApplicationController
  skip_before_action :verify_authenticity_token

  def recibir
    #TODO: ... todo :$
    factura = obtener_factura(params[:idfactura])
    oc = Oc.find_by idoc: factura['oc']
    if factura['proveedor'].to_s != $groupid
      puts "--------Factura RECHAZADA---------! No soy el proveedor de la factura"
    elsif oc == nil
      puts "--------Factura RECHAZADA---------! No tengo la Oc en mi base de datos (Mi empresa no la generó)"
    elsif oc['idfactura'].to_s != params[:idfactura].to_s
      puts "--------Factura RECHAZADA---------! La id de la factura no corresponde con la OC. oc.idfactura: " + oc['idfactura'].to_s + " --param: " + params[:idfactura]
    else
      puts "--------Factura Aceptada---------"
      #TODO: El resto...
    end
    render json: factura
  end

  private

  def obtener_factura(idFactura)
    require 'httparty'
    begin # Intentamos realizar conexión externa y obtener OC
      puts "--------Obteniendo Factura--------------"
      url = "http://mare.ing.puc.cl/facturas/"
      result = HTTParty.get(url+idFactura,
              headers: {
                'Content-Type' => 'application/json'
              })
      json = JSON.parse(result.body)
      #TODO: Actualizar OC local
      puts "--------Factura Obtenida--------------"
      return json[0]
    rescue => ex # En caso de excepción retornamos error
      logger.error ex.message
      render json: {"error": ex.message}, status: 503 and return
    end
  end

end
