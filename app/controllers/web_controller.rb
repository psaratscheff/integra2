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

    if stock_disponible(sku) < cantidad
      url = params[:url]
      if url.include?('?')
        redirect_to params[:url] and return
      else
        redirect_to params[:url] + '?enough-stock=false' and return
      end
    end

    total = cantidad * Item.find(sku).Precio_Unitario

    boleta = emitirBoleta($groupid, 'b2c', total)

    id_boleta = boleta['_id']
    url_fail = 'http://integra2.ing.puc.cl/handle_payment/fail'
    url_ok = 'http://integra2.ing.puc.cl/handle_payment/success'

    url = urlWebPay(id_boleta, url_fail, url_ok)

    redirect_to url
  end

  def success
    render html: 'WUHU! Compra realizada :D'
  end

  def fail
    render html: 'Tu compra ha fallado porque eres rasca ¬¬'
  end
end
