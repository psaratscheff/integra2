class TasksController <ApplicationController

	def producirMateriaPrima(sku): #Solo puede entrar a la funcion si sku = 2,12,21,28 o 32
		stock = consultar_stock(sku).to_i
		case sku
		when "2"
		  tamanoLote = 150
		  costoProduccionUnidad = 513
		when "12"
		  tamanoLote = 400
		  costoProduccionUnidad = 2581
		when "21"
		  tamanoLote = 100
		  costoProduccionUnidad = 1272
		when "28"
		  tamanoLote = 500
		  costoProduccionUnidad = 1138
		when "32"
		  tamanoLote = 230
		  costoProduccionUnidad = 996
		end

		minSku = 800 #TODO: Elegir minimo y maximo
		maxSku = 1200 #Todos los productos tendran el mismo maximo
		costoLote = costoProduccionUnidad*tamanoLote

		if stock <= minSku
			cantidadProducir = maxSku-stock
			cantidadLotes =  (cantidadProducir/tamañoLote) #La parte entera del numero
			costoPedido = cantidadLotes*costoLote
			#Hacer la transacccion
			cuentaOrigen = getIdBanco('2')
			cuentaDestino = cuentaFabrica() #TODO: Revisar formato
			trx = transferir(cuentaOrigen,cuentaDestino,costoPedido)   #Definida en Application Controller
			trxId = trx['_id']
			#Producir el stock
			require 'httparty'
		    begin # Intentamos realizar conexión externa y obtener OC
		      puts "--------Produciendo Stock --------------"
		      url = "http://integracion-2016-dev.herokuapp.com/bodega/fabrica/fabricar"
		      result = HTTParty.put(url,
		          body:    {
		                      sku: sku,
		                      trxId: trxId #TODO: Revisar sintexis
		                      cantidad: cantidadLotes #TODO: Revisar si son lotes o unidades
		                    }.to_json,
		          headers: {
		            'Content-Type' => 'application/json',
		            'Authorization' => 'INTEGRACIONgrupo2:'+encode('PUT'+sku+cantidadLotes+trxId)
		          })

		      detallesPedido = JSON.parse(result.body)
		    rescue => ex # En caso de excepción retornamos error
		      logger.error ex.message
		      puts "error 1015"
		      render json: {"error": ex.message}, status: 503 and return
		    end

		    #TODO: Checkear que los pedidos lleguen a nuestra bodega de despacho
		    #TODO: Movelos a otras bodegas.

	end

end

