class WebController < ApplicationController
  def load_product
    @sku = params[:sku]
    respond_to do |format|
      format.js # actually means: if the client ask for js -> return file.js
    end
  end

  def procesar_compra
    sku = params[:sku]
    cantidad = params[:cantidad].to_i
    direccion = params[:direccion]

    if stock_disponible(sku) < cantidad
      url = params[:url]
      if url.include?('?')
        redirect_to params[:url] and return
      else
        redirect_to params[:url] + '?enough-stock=false' and return
      end
    end

    total = cantidad * Item.find(sku).Precio_Unitario
    monto_bruto =  total / 1.19
    iva = monto_bruto * 0.19

    boleta = emitirBoleta($groupid, 'b2c', total)

    id_boleta = boleta['_id']
    url_fail = 'http://integra2.ing.puc.cl/spree' + '?success=false'
    url_ok = 'http://integra2.ing.puc.cl/spree' + '?success=true&idBoleta=' + id_boleta + '&montoBruto=' + monto_bruto + '&iva=' + iva + '&total=' + total + '&direccion=' + direccion

    url = urlWebPay(id_boleta, url_fail, url_ok)

    redirect_to url
  end
end
