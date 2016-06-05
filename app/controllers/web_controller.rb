class WebController < ApplicationController
  def load_product
    @sku = params[:sku]
    respond_to do |format|
      format.js # actually means: if the client ask for js -> return file.js
    end
  end

  def procesar_compra
    puts "-------------Procesando Compra-----------"
    sku = params[:sku]
    cantidad = params[:cantidad].to_s
    direccion = params[:direccion]

    if stock_disponible(sku) < cantidad.to_i
      url = params[:url]
      if url.include?('?')
        redirect_to params[:url] and return
      else
        redirect_to params[:url] + '?enough-stock=false' and return
      end
    end

    total = (cantidad.to_i * Item.find(sku).Precio_Unitario).to_s
    monto_bruto = (total.to_i / 1.19).to_i.to_s
    iva = (monto_bruto.to_i * 0.19).to_i.to_s

    boleta = emitirBoleta($groupid, 'b2c', total)

    id_boleta = boleta['_id']
    url_fail = 'http://integra2.ing.puc.cl/spree' + '?success=false'
    url_ok = 'http://integra2.ing.puc.cl/spree' + '?success=true&idBoleta=' + id_boleta + '&montoBruto=' + monto_bruto + '&iva=' + iva + '&total=' + total + '&direccion=' + direccion + '&sku=' + sku + '&cantidad=' + cantidad
    url = urlWebPay(id_boleta, url_fail, url_ok)
    redirect_to url
    puts "-------------Compra Procesada-----------"
  end

  def success
    puts '-----------Despachando Producto B2C----------------------------------'
    id_boleta = params[:id_boleta]
    direccion = params[:direccion]
    sku = params[:sku]
    cantidad = params[:cantidad]

    puts '--Despacho--B2C--id_boleta: ' + id_boleta + '--direccion: ' + direccion + '--sku: ' + sku + '--cantidad: ' + cantidad + '--'
    almacenes = lista_de_almacenes
    items_despachados = 0
    almacenes.each do |almacen|

      break if items_despachados >= cantidad.to_i
      next if almacen['despacho']
      productos = stock_de_almacen(almacen['_id'], sku)
      productos.each do |producto|
        break if items_despachados == cantidad.to_i
        id_producto = producto['_id']
        mover_a_despacho(id_producto)
        despachar_delete_producto(id_producto, direccion, Item.find(sku.to_i).Precio_Unitario, id_boleta)
        items_despachados += 1
      end
    end
    respond_to do |format|
      format.js
    end
    puts '-------------Producto B2C Despachado!--------------------------------'
  end
end
