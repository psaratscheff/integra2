desc "Say Hello world"
task :say_hi do
  puts "Hello world!"
  result = HTTParty.get("http://localhost:3000/api/documentacion")
end

desc "Procesar OC internacionales"
task :procesar_sftp do
  url = "http://integracion-2016-dev.herokuapp.com/bodega/"
  result = HTTParty.get(url+"almacenes",
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => 'INTEGRACIONgrupo2:z7gr473SiTMjSW8v+J6lqUwqIGo='
          })
  lista_de_almacenes = JSON.parse(result.body)
  Net::SFTP.start('mare.ing.puc.cl', 'integra2', :password => 'fUgW9wJG') do |sftp|
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
        stock = 0

        lista_de_almacenes.each do |almacen|
          url = "http://integracion-2016-dev.herokuapp.com/bodega/"
          result = HTTParty.get(url+"stock"+"?almacenId="+almacen["_id"]+"&"+"sku="+sku.to_s,
                  headers: {
                    'Content-Type' => 'application/json',
                    'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+almacenId+sku.to_s)
                  })
          stock += JSON.parse(result.body).count() unless almacen["despacho"]
        end

        if stock >= qty && (sku == "2" || sku == "12" || sku == "21" || sku == "28" || sku == "32")
          # Obtener OC
          url = "http://mare.ing.puc.cl/oc/"
          result = HTTParty.get(url+"obtener/"+idoc.to_s,
                  headers: {
                    'Content-Type' => 'application/json',
                    'Authorization' => 'INTEGRACIONgrupo2:'+encode('GET'+idoc.to_s)
                  })
          json = JSON.parse(result.body)

          if json.count() > 1
            raise "Error: se retornó más de una OC para el mismo id"
          end
          oc = json[0]
          # Validar la OC
          validado = false
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

          if validado
            # Aceptar OC
            HTTParty.post(url+"recepcionar/"+idoc.to_s,
                  headers: {
                    'Content-Type' => 'application/json'
                  })
            # Generar factura
            HTTParty.put(url,
                  body: {
                    oc: idoc
                  }.to_json,
                  headers: {
                    'Content-Type' => 'application/json'
                  })
            #TODO: Despachar...
          else
            # Rechazar OC
            HTTParty.post(url+"rechazar/"+id.to_s,
                  body: {
                    rechazo: 'Precio menor al estipulado'
                  }.to_json,
                  headers: {
                    'Content-Type' => 'application/json'
                  })
          end


          url = "http://mare.ing.puc.cl/oc/"
          result = HTTParty.put(url+"crear",
              body:    {
                          cliente: "internacional",
                          proveedor: proveedor,
                          sku: sku,
                          fechaEntrega: fechaEntrega,
                          precioUnitario: precio,
                          cantidad: qty,
                          canal: "ftp"
                        }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
        else
        HTTParty.post(url+"rechazar/"+id.to_s,
              body: {
                rechazo: 'No hay stock / No producimos el producto solicitado'
              }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
        end
      end
    end

  end
  render json: {"Proceso terminado exitosamente?": true}
end
