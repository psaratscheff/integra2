class DashboardController < ApplicationController
  
  def index
  end

  def bodega
    @disponibleBodega = 100
    @ocupadoBodega = 50
  end

 def almacen1
    @disponibleAlmacen1 = 100
    @ocupadoAlmacen1= 50
  end

<<<<<<< HEAD
 def almacen2
    @disponibleAlmacen2 = 100
    @ocupadoAlmacen2 = 50
  end

 def recepcion
    @disponibleRecepcion = 100
    @ocupadoRecepcion = 50
  end
=======
=begin
    result = HTTParty.post(url,
                  body:    {
                  fechaInicio: ,
                  fechaFin: asdasd,
                  id: aasdsad,
                }.to_json,
                  headers: {
                    'Content-Type' => 'application/json'
                })

    json = JSON.parse(result.body)
=end
>>>>>>> e764a98f50450e01416420ea3554f950ffb9bb67

 def despacho
    @disponibleDespacho = 100
    @ocupadoDespacho = 50
  end

 def pulmon
    @disponiblePulmon = 100
    @ocupadoPulmon = 50
  end

  def productos
    @huevo = 1
    @cerealDeAvena = 2
    @algodon = 3 
    @telaDeLino = 4
    @cuero = 5
  end

  def materiasprimas
    @avena = 1
    @cacao = 2
    @azucar = 3
    @lino =  4
  end

  def trx
    @dia = params[:dia]
    @mes = params[:mes]
    @año = params[:año]
    @fecha = @dia+" - "+@mes+" - "+@año
    @numeroTrx = numeroTrxDia(@dia.to_i,@mes.to_i,@año.to_i)
    @transacciones = cartolaTrxDia(@dia.to_i,@mes.to_i,@año.to_i)
  end

  def saldobanco
    url = 'http://mare.ing.puc.cl/banco/cuenta/'+ $bancoid
    result = HTTParty.get(url,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    plata = json[0]['saldo'].to_s
    @saldo = "$"+plata
  end


  #----------------Otros-----------------

  def numeroTrxDia(dia, mes, año)
    url = 'http://mare.ing.puc.cl/banco/cartola'

    ayer1 = Date.new(año,mes,dia).to_time.to_i
    ayer2= ayer1.to_s+"000"
    hoy1 = ayer1 + 86400
    hoy2 = hoy1.to_s+"000"


    result = HTTParty.post(url,
                    body:    {
                      fechaInicio:ayer2,
                      fechaFin:hoy2,
                      id: $bancoid,

                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    cantidadTrx = json['total']
    return cantidadTrx
  end

  def cartolaTrxDia(dia, mes, año)
    url = 'http://mare.ing.puc.cl/banco/cartola'
    ayer1 = Date.new(año,mes,dia).to_time.to_i
    ayer2= ayer1.to_s+"000"
    hoy1 = ayer1 + 86400
    hoy2 = hoy1.to_s+"000"

    result = HTTParty.post(url,
                    body:    {
                      fechaInicio:ayer2,
                      fechaFin:hoy2,
                      id: $bancoid,

                    }.to_json,
              headers: {
                'Content-Type' => 'application/json'
              })
    json = JSON.parse(result.body)
    cartola = json['data']
    return cartola
  end

end
