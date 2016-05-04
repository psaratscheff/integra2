class TasksController < ApplicationController

  def procesar_sftp
    Net::SFTP.start('mare.ing.puc.cl', 'integra2', :password => 'fUgW9wJG') do |sftp|
      count = 0
      # download a file or directory from the remote host
      #sftp.download!("/pedidos", "public/pedidos", :recursive => true)
      # list the entries in a directory
      sftp.dir.foreach("/pedidos") do |entry|
        if entry.name[0]!="."
          data = sftp.download!("/pedidos/"+entry.name)
          id = three_letters = data[/<id>(.*?)<\/id>/m, 1]
          sku = three_letters = data[/<sku>(.*?)<\/sku>/m, 1]
          qty = three_letters = data[/<qty>(.*?)<\/qty>/m, 1]
          puts "ID: "+id+" // sku: "+ sku + " // qty: "+qty

          # Metodo definidos en application_controller
          stock = consultar_stock(sku).to_i
          qty = qty.to_i
          # Revisamos que tengamos stock del producto y que sea un producto que nosotros producimos
          if stock >= qty && (sku == "2" || sku == "12" || sku == "21" || sku == "28" || sku == "32")
            # puts "------------------------>  Tengo stock del producto y soy proveedor de este"
            # Obtener OC - Metodo definidos en application_controller
            oc = obtener_oc(id)


            validado = false
            # Ahora validamos que el precio que nos pagaran sea el mismo que tenemos o mayor a este
            case sku
            when "2"
              validado = oc["precioUnitario"] >= 718
            when "12"
              validado = oc["precioUnitario"] >= 7413
            when "21"
              validado = oc["precioUnitario"] >= 1462
            when "28"
              validado = oc["precioUnitario"] >= 2382
            when "32"
              validado = oc["precioUnitario"] >= 1135
            end

            oc = transform_oc(oc)
            localOc = Oc.new(oc)
            localOc.save!

            if validado
              count = count + 1
              puts "Ordenes procesadas:" + count.to_s
              puts "------------------------> Voy a aceptar la OC"
              aceptar_oc(id)
              # puts "------------------------> He aceptado oc"

              # Generar facura para OC
              # puts "------------------------> Voy a generar la factura"
              generar_factura(id)
              # puts "------------------------> He generado la factura"
              # Despachar productos


            else
              count = count + 1
              puts "Ordenes procesadas:" + count.to_s
              puts "------------------------> Voy a rechazar la OC porque el precio esta mal"
              rechazar_oc(id)
              # puts "------------------------> He rechazado la OC"
            end
          # En caso que no tengamos stock o nos pidan un producto que no procesamos rechazamos la oc
          else
            # puts "------------------------> No produzco el producto o no soy proveedor "
            oc = obtener_oc(id)

            oc = transform_oc(oc)
            # puts "------------------------> oc transformada "
            puts oc.to_s
            localOc = Oc.new(oc)

            localOc.save!
            count = count + 1
            puts "Ordenes procesadas:" + count.to_s
            puts "------------------------> Voy a rechazar la OC porque no tengo stock o no soy proveedor"
            puts id.to_s
            rechazar_oc(id)
            # puts "------------------------> He rechazado la OC"
          end

        end

      end

      render json: {"Proceso terminado exitosamente?": true}

    end

  end

end
