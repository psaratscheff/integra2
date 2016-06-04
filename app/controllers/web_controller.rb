class WebController < ApplicationController
  def procesar_compra
    sku = params[:sku]
    cantidad = params[:cantidad].to_i

    total = cantidad * Item.find(sku).Precio_Unitario

    boleta = emitirBoleta($groupid, 'b2c', total)

    idBoleta = boleta['_id']
    urlFail = 'http://integra2.ing.puc.cl/handle_payment/fail'
    urlOk = 'http://integra2.ing.puc.cl/handle_payment/success'

    url = urlWebPay(idBoleta, urlFail, urlOk).to_s

    redirect_to url
  end

  def success
    render html: 'WUHU! Compra realizada :D'
  end

  def fail
    render html: 'Tu compra ha fallado porque eres rasca ¬¬'
  end
end
