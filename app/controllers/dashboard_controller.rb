class DashboardController < ApplicationController
  def index


  	# ------------Graficas de Barra para los productos -----------
  	sku2 = 1
  	sku12 = 2
  	sku21 = 3
  	sku28 = 4
  	sku32 = 5

  	infoProductos = "2(Huevo)|12(Avena)|21(Algodon)|28(Tela de Lino)|32(Cuero)"
  	
  	@productosBar = Gchart.bar(

            :bar_colors => ['A10200'],
            :title => ".                  Cantidades disponibles por SKU", 
            #:bg => 'EFEFEF', 
            :legend => ['Unidades de producto por SKU'],
            :data => [sku2, sku12, sku21, sku28, sku32],
            :stacked => false,
            :legend_position => 'bottom',
            :axis_with_labels => [['x']],
            :max_value => 10,
            :min_value => 0,
            :axis_labels => [["2|12|21|28|32"]],
            )    

	sku15=1
	sku20=2
	sku25=3
	sku37=4

	#Ceral de avena necesita 15,20,25, Tela de lino necesita 37
	infoMateriasPrimas = "15(Avena), 20(Cacao), 25(Azucar), 37(Lino)"

  	@materiasPrimasBar = Gchart.bar(

            :bar_colors => ['A10200'],
            :title => ".                  Materias  Primas", 
            #:bg => 'EFEFEF', 
            :legend => ['Unidades de producto por SKU'],
            :data => [sku15, sku20, sku25, sku37],
            :stacked => false,
            :legend_position => 'bottom',
            :axis_with_labels => [['x']],
            :max_value => 10,
            :min_value => 0,
            :axis_labels => [["15|20|25|37"]],

            )    


  		# ------------Graficas de Pie para los almacenes -----------


  	@bodegaPie=Gchart.pie(
                    :title  => "Espacio disponible en toda la bodega",
                    :legend => ['Espacio Disponible', 'Espacio Ocupado'],
                    :custom => "chco=FFF110,FF0000",
                    :data   => [100, 1000],
  			)


  	@almacen1Pie=Gchart.pie(
                    :title  => "Espacio disponible en toda la bodega",
                    :legend => ['Espacio Disponible', 'Espacio Ocupado'],
                    :custom => "chco=FFF110,FF0000",
                    :data   => [100, 1000],
  			)

  	@almacen2Pie=Gchart.pie(
                    :title  => "Espacio disponible en toda la bodega",
                    :legend => ['Espacio Disponible', 'Espacio Ocupado'],
                    :custom => "chco=FFF110,FF0000",
                    :data   => [100, 1000],
  			)

  	@pulmonPie=Gchart.pie(
                    :title  => "Espacio disponible en toda la bodega",
                    :legend => ['Espacio Disponible', 'Espacio Ocupado'],
                    :custom => "chco=FFF110,FF0000",
                    :data   => [100, 1000],
  			)

  	@recepcionPie=Gchart.pie(
                    :title  => "Espacio disponible en toda la bodega",
                    :legend => ['Espacio Disponible', 'Espacio Ocupado'],
                    :custom => "chco=FFF110,FF0000",
                    :data   => [100, 1000],
  			)

  	@despachoPie=Gchart.pie(
                    :title  => "Espacio disponible en toda la bodega",
                    :legend => ['Espacio Disponible', 'Espacio Ocupado'],
                    :custom => "chco=FFF110,FF0000",
                    :data   => [100, 1000],
  			)



  		# ------------Analisis Financiero -----------

  	saldo = 100000

  	@saldoCuenta = Gchart.bar(

            :bar_colors => ['A10200'],
            :title => ".                  Saldo  Cuenta", 
            #:bg => 'EFEFEF', 
            :legend => ['Pesos Chilenos'],
            :data => [5],
            :stacked => false,
            :legend_position => 'bottom',
            :axis_with_labels => [['x']],
            :max_value => 10,
            :min_value => 0,
            :axis_labels => [["$"]],

            )    

 
  end

end
