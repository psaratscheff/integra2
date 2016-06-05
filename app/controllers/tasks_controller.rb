class TasksController < ApplicationController
	# Cuando el metodo este listo hay que agregarle que procese solo las oc que no han sido procesadas ya
	def procesar_sftp
		puts "------------INICIANDO PROCESO SFTP EN BACKGROUND----------------"
		background do # Función background definida en ApplicationController
			if $ambiente
					urlServidor = 'moto.ing.puc.cl'
					pass = '7ezT4Mz6'
			else
					urlServidor = 'mare.ing.puc.cl'
					pass = 'fUgW9wJG'
			end
			begin
				Net::SFTP.start(urlServidor, 'integra2', :password => pass) do |sftp|
					count = 0
					# download a file or directory from the remote host
					#sftp.download!("/pedidos", "public/pedidos", :recursive => true)
					# list the entries in a directory
					sftp.dir.foreach("/pedidos") do |entry|
						if entry.name[0]!="." && ((((Time.now.to_i).to_s + "000").to_i - 172800000)  < entry.name.split('.')[0].to_i) # Pedidos de los últimos dos días
							puts (entry.name.split('.')[0].to_i).to_s
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
									puts "------------------------> Voy a aceptar la OC"
									aceptar_oc(id)
									# puts "------------------------> He aceptado oc"
									# Generar facura para OC
									# puts "------------------------> Voy a generar la factura"
									factura = generar_factura(id)
									# puts factura.to_s
									# factura = JSON.parse(factura)
									# puts factura.to_s
									idfactura = factura["_id"]
									puts "------------------------> " + factura.to_s
									puts "------------------------> " + idfactura.to_s
									# puts "------------------------> He generado la factura"
									# Despachar productos

									despacharInternacional(idfactura, factura)
									puts "------------------------> "
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
								puts "------------------------> oc transformada: " + oc.to_s
								oc.delete("rechazo")

								localOc = Oc.new(oc)
								localOc.save!
								count = count + 1
								puts "Ordenes procesadas:" + count.to_s
								puts "------------------------> Voy a rechazar la OC porque no tengo stock o no soy proveedor: " + id.to_s
								rechazar_oc(id)
								# puts "------------------------> He rechazado la OC"
							end
						end
					end
				end
			rescue => ex # En caso de excepción retornamos error
	      logger.error ex.message
	      puts "error 1050: " + ex.message
	    end
		end
		render html: "Solicitud de procesamiento enviada..."
	end

	def producirMP
		sku = params[:sku]
		producirMateriaPrima(sku)
	end

	def producirMateriaPrima(sku) #Solo puede entrar a la funcion si sku = 2,21,32
		stock = consultar_stock(sku).to_i

		case sku
		when "2"
		  tamanoLote = 150
		  costoProduccionUnidad = 513
		when "21"
		  tamanoLote = 100
		  costoProduccionUnidad = 1272
		when "32"
		  tamanoLote = 230
		  costoProduccionUnidad = 996
		end

		minSku = 800 #TODO: Elegir minimo y maximo
		maxSku = 1200 #Todos los productos tendran el mismo maximo
		costoLote = costoProduccionUnidad*tamanoLote

		if stock <= minSku
			cantidadProducir = maxSku-stock
			cantidadLotes =  (cantidadProducir/tamanoLote) #La parte entera del numero
			costoPedido = cantidadLotes*costoLote
			#Hacer la transacccion
			cuentaOrigen = getIdBanco('2')
			cuentaDestino = cuentaFabrica() #TODO: Revisar formato
			trx = transferir(cuentaOrigen,cuentaDestino,costoPedido)   #Definida en Application Controller
			trxId = trx['_id']
			#Producir el stock
			cantidadSolicitar = cantidadLotes*tamanoLote
			require 'httparty'
	    begin # Intentamos realizar conexión externa y obtener OC
	      puts "--------Produciendo Stock (Materia Prima)--------------"
				url = $urlBodega + 'fabrica/fabricar'
				result = HTTParty.put(url,
	          body:    {
	                      sku: sku.to_s,
	                      trxId: trxId, #TODO: Revisar sintexis
	                      cantidad: cantidadSolicitar #TODO: Revisar si son lotes o unidades
	                    }.to_json,
	          headers: {
	            'Content-Type' => 'application/json',
	            'Authorization' => 'INTEGRACIONgrupo2:'+encode('PUT'+sku.to_s+cantidadSolicitar.to_s+trxId)
	          })
	      puts "(Produciendo_Stock_Prima_?)Respuesta de la contraparte: " + result.body.to_s
	      detallesPedido = JSON.parse(result.body)
				puts "--------Stock Producido (Materia Prima)--------------" + detallesPedido.to_s
	    rescue => ex # En caso de excepción retornamos error
	      logger.error ex.message
	      puts "error 1015"
	      render json: { error: ex.message }, status: 503 and return
	    end
	    #TODO: Checkear que los pedidos lleguen a nuestra bodega de despacho
	    #TODO: Movelos a otras bodegas.
		end
		render json: { success: true}
	end

	def producirProductosElaborados(sku) #Solo puede entrar a la funcion si sku = 12 o 28
		stock = consultar_stock(sku).to_i
		materiasPrimas = []
		case sku
		when "12"
		  tamanoLote = 400
		  costoProduccionUnidad = 2581
		  materiasPrimas[0] = 25.to_s #Azucar
		  materiasPrimas[1] = 20.to_s #Cacao
		  materiasPrimas[2] = 15.to_s #Avena
		when "28"
		  tamanoLote = 500
		  costoProduccionUnidad = 1138.to_s
		  materiasPrimas[0] = 37.to_s #Lino
		end

		cantidadMateriaPrimaPorLote = {'25':133,'20':147,'15':113,'37':440} # TODO: Funciona?
		minSku = 800 # TODO: Elegir minimo y maximo
		maxSku = 1200 # Todos los productos tendran el mismo maximo
		costoLote = costoProduccionUnidad*tamanoLote


		if stock <= minSku

			cantidadProducir = maxSku-stock
			cantidadLotes =  (cantidadProducir/tamanoLote) #La parte entera del numero
			costoPedido = cantidadLotes*costoLote

			#Reviso si tengo el stock de materias primas necesario

			#TODO: Revisar logica de produccion. Por ahora, si quiero producir 3 lotes
				#pero solo puedo producir 2, no produzco

			tengoStock = true
			materiasPrimas.each do |materiaPrima|
				if cantidadMateriaPrimaPorLote['materiaPrima']*cantidadLotes < consultar_stock(materiaPrima).to_i
					tengoStock = false
				end
			end

			if tengoStock

				#TODO: Mover al almacen de despacho los productos necesarios

				#Transferir
				cuentaOrigen = getIdBanco('2')
				cuentaDestino = cuentaFabrica() #TODO: Revisar formato
				trx = transferir(cuentaOrigen,cuentaDestino,costoPedido)   #Definida en Application Controller
				trxId = trx['_id']
				#Producir el stock
				require 'httparty'
				cantidadSolicitar = cantidadLotes*tamanoLote
				begin # Intentamos realizar conexión externa y obtener OC
					puts "--------Produciendo Stock --------------"
					url = $urlBodega + 'fabrica/fabricar'

					result = HTTParty.put(url,
																body:    {
																						sku: sku.to_s,
																						trxId: trxId, #TODO: Revisar sintexis
																						cantidad: cantidadSolicitar #TODO: Revisar si son lotes o unidades
																					}.to_json,
																headers: {
																	'Content-Type' => 'application/json',
											            'Authorization' => 'INTEGRACIONgrupo2:'+encode('PUT'+sku.to_s+cantidadSolicitar.to_s+trxId)
																})
					detallesPedido = JSON.parse(result.body)
					puts "--------Stock Producido (Producto Procesado)--------------" + detallesPedido.to_s
				rescue => ex # En caso de excepción retornamos error
					logger.error ex.message
					puts "error 1015"
					render json: { error: ex.message }, status: 503 and return
				end

			end

			    #TODO: Checkear que los pedidos lleguen a nuestra bodega de despacho
			    #TODO: Moverlos a otras bodegas.
		end
	end

	def limpiarBodegaRepecepcion
		skus = [params[:sku]]
		almacenId = $recepcionid #Variable global definida en application_controller
		skus.each do |sku|
			productos = stock_de_almacen(almacenId, sku).limit(10)
			productos.each do |pr|
				if producto = mover_producto_almacen(pr['_id'], $bodegaid) # Variable global definida en AppCtrlr
					producto = Producto.new(_id: pr['_id'], sku: sku, estado: 'disponible', almacen_id: $bodegaid)
					almacen = Almacen.find_by(_id: $bodegaid)
					agregar_producto(producto, almacen)
				end
			end
		end
		render json: { success: true }
	end

	def limpiarBodegaDespacho
		skus = [2,12,21,28,32,25,20,15,37] #Productos que podríamos tener en la bodega
		almacenId = $despachoid
		skus.each do |sku|
			while (productos = stock_de_almacen(almacenId, sku)).count > 0
				productos.each do |producto|
					idProducto = producto['_id']
					mover_producto_almacen(idProducto, '572aad41bdb6d403005fb1be')
				end
			end
		end
		render json: { success: true }
	end
end
