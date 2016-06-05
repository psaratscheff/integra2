# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
include HmacHelper # Para utilizar la función de hashing
include SeedHelper

if Item.count == 0
  p 'No se encontraron items... Cargando Items'
  Item.create!([{
    Sku: 1,
    Descripcion: "Pollo",
    Tipo: "Materia prima",
    Grupo: "7", Unidades: "Kg",
    Costo_Unitario: 892,
    Lote: 300,
    Tiempo_Medio: 2.041,
    Precio_Unitario: 1159,
    Sku1: "",
    Sku2: "",
    Sku3: "",
    Sku4: ""
  },
  {
    Sku: 2,
    Descripcion: "Huevo",
    Tipo: "Materia prima",
    Grupo: "2",
    Unidades: "Un",
    Costo_Unitario: 513,
    Lote: 150,
    Tiempo_Medio: 3.736,
    Precio_Unitario: 718,
    Sku1: "",
    Sku2: "",
    Sku3: "",
    Sku4: ""
  },
  {
  Sku: 3, Descripcion: "Maíz", Tipo: "Materia prima", Grupo: "10", Unidades: "Kg", Costo_Unitario: 1468, Lote: 30, Tiempo_Medio: 3.532, Precio_Unitario: 1805, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  },
  {
  Sku: 4, Descripcion: "Aceite de Maravilla", Tipo: "Producto procesado", Grupo: "11", Unidades: "Lts", Costo_Unitario: 863, Lote: 200, Tiempo_Medio: 3.026, Precio_Unitario: 3112, Sku1: "38", Sku2: "", Sku3: "", Sku4: ""},
  {
  Sku: 5, Descripcion: "Yogur ", Tipo: "Producto procesado", Grupo: "11", Unidades: "Lts", Costo_Unitario: 2197, Lote: 600, Tiempo_Medio: 3.526, Precio_Unitario: 26027, Sku1: "49", Sku2: "6", Sku3: "41", Sku4: ""},
  {
  Sku: 6, Descripcion: "Crema", Tipo: "Producto procesado", Grupo: "3", Unidades: "Lts", Costo_Unitario: 2402, Lote: 30, Tiempo_Medio: 0.979, Precio_Unitario: 9678, Sku1: "49", Sku2: "7", Sku3: "", Sku4: ""},
  {
  Sku: 7, Descripcion: "Leche", Tipo: "Materia prima", Grupo: "12", Unidades: "Lts", Costo_Unitario: 941, Lote: 1000, Tiempo_Medio: 4.248, Precio_Unitario: 1307, Sku1: "", Sku2: "", Sku3: "", Sku4: ""},
  {
  Sku: 8, Descripcion: "Trigo", Tipo: "Materia prima", Grupo: "3", Unidades: "Kg", Costo_Unitario: 1313, Lote: 100, Tiempo_Medio: 0.784, Precio_Unitario: 1601, Sku1: "", Sku2: "", Sku3: "", Sku4: ""},
  {
  Sku: 9, Descripcion: "Carne", Tipo: "Materia prima", Grupo: "10", Unidades: "Kg", Costo_Unitario: 1397, Lote: 620, Tiempo_Medio: 4.279, Precio_Unitario: 1704, Sku1: "", Sku2: "", Sku3: "", Sku4: ""},
  {
  Sku: 10, Descripcion: "Pan Marraqueta", Tipo: "Producto procesado", Grupo: "7", Unidades: "Kg", Costo_Unitario: 2572, Lote: 900, Tiempo_Medio: 3.677, Precio_Unitario: 15718, Sku1: "23", Sku2: "26", Sku3: "4", Sku4: "27"
  }, {Sku: 11, Descripcion: "Margarina ", Tipo: "Producto procesado", Grupo: "4", Unidades: "Kg", Costo_Unitario: 1839, Lote: 900, Tiempo_Medio: 4.118, Precio_Unitario: 6238, Sku1: "4", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 12, Descripcion: "Cereal Avena ", Tipo: "Producto procesado", Grupo: "2", Unidades: "Kg", Costo_Unitario: 2581, Lote: 400, Tiempo_Medio: 3.056, Precio_Unitario: 7413, Sku1: "25", Sku2: "20", Sku3: "15", Sku4: ""
  }, {Sku: 13, Descripcion: "Arroz", Tipo: "Materia prima", Grupo: "6", Unidades: "Kg", Costo_Unitario: 1286, Lote: 1000, Tiempo_Medio: 2.89, Precio_Unitario: 1504, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 14, Descripcion: "Cebada", Tipo: "Materia prima", Grupo: "3", Unidades: "Kg", Costo_Unitario: 696, Lote: 1750, Tiempo_Medio: 1.355, Precio_Unitario: 932, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 15, Descripcion: "Avena", Tipo: "Materia prima", Grupo: "12", Unidades: "Kg", Costo_Unitario: 969, Lote: 480, Tiempo_Medio: 3.965, Precio_Unitario: 1182, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 16, Descripcion: "Pasta de Trigo ", Tipo: "Producto procesado", Grupo: "4", Unidades: "Kg", Costo_Unitario: 2292, Lote: 1000, Tiempo_Medio: 2.992, Precio_Unitario: 9793, Sku1: "23", Sku2: "26", Sku3: "2", Sku4: ""
  }, {Sku: 17, Descripcion: "Cereal Arroz ", Tipo: "Producto procesado", Grupo: "6", Unidades: "Kg", Costo_Unitario: 2184, Lote: 1000, Tiempo_Medio: 2.052, Precio_Unitario: 8779, Sku1: "25", Sku2: "20", Sku3: "13", Sku4: ""
  }, {Sku: 18, Descripcion: "Pastel ", Tipo: "Producto procesado", Grupo: "8", Unidades: "Un", Costo_Unitario: 2140, Lote: 200, Tiempo_Medio: 0.941, Precio_Unitario: 9474, Sku1: "23", Sku2: "2", Sku3: "7", Sku4: ""
  }, {Sku: 19, Descripcion: "Sémola", Tipo: "Materia prima", Grupo: "1", Unidades: "Kg", Costo_Unitario: 1428, Lote: 1420, Tiempo_Medio: 4.033, Precio_Unitario: 1613, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 20, Descripcion: "Cacao", Tipo: "Materia prima", Grupo: "9", Unidades: "Kg", Costo_Unitario: 1280, Lote: 60, Tiempo_Medio: 4.101, Precio_Unitario: 1612, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 21, Descripcion: "Algodón", Tipo: "Materia prima", Grupo: "2", Unidades: "Kg", Costo_Unitario: 1272, Lote: 100, Tiempo_Medio: 1.157, Precio_Unitario: 1462, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 22, Descripcion: "Mantequilla ", Tipo: "Producto procesado", Grupo: "11", Unidades: "Kg", Costo_Unitario: 1891, Lote: 400, Tiempo_Medio: 1.951, Precio_Unitario: 12725, Sku1: "6", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 23, Descripcion: "Harina", Tipo: "Producto procesado", Grupo: "7", Unidades: "Kg", Costo_Unitario: 1534, Lote: 300, Tiempo_Medio: 3.95, Precio_Unitario: 4294, Sku1: "8", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 24, Descripcion: "Tela de Seda ", Tipo: "Producto procesado", Grupo: "8", Unidades: "Mts", Costo_Unitario: 1442, Lote: 400, Tiempo_Medio: 0.695, Precio_Unitario: 2774, Sku1: "33", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 25, Descripcion: "Azúcar", Tipo: "Materia prima", Grupo: "6", Unidades: "Kg", Costo_Unitario: 782, Lote: 560, Tiempo_Medio: 1.515, Precio_Unitario: 1016, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 26, Descripcion: "Sal", Tipo: "Materia prima", Grupo: "8", Unidades: "Kg", Costo_Unitario: 753, Lote: 144, Tiempo_Medio: 0.784, Precio_Unitario: 926, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 27, Descripcion: "Levadura", Tipo: "Materia prima", Grupo: "1", Unidades: "Kg", Costo_Unitario: 1084, Lote: 620, Tiempo_Medio: 2.717, Precio_Unitario: 1376, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 28, Descripcion: "Tela de Lino ", Tipo: "Producto procesado", Grupo: "2", Unidades: "Mts", Costo_Unitario: 1138, Lote: 500, Tiempo_Medio: 3.754, Precio_Unitario: 2382, Sku1: "37", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 29, Descripcion: "Tela de Lana ", Tipo: "Producto procesado", Grupo: "10", Unidades: "Mts", Costo_Unitario: 1868, Lote: 400, Tiempo_Medio: 1.961, Precio_Unitario: 4865, Sku1: "31", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 30, Descripcion: "Tela de Algodón ", Tipo: "Producto procesado", Grupo: "12", Unidades: "Mts", Costo_Unitario: 1698, Lote: 500, Tiempo_Medio: 3.865, Precio_Unitario: 3918, Sku1: "21", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 31, Descripcion: "Lana", Tipo: "Materia prima", Grupo: "3", Unidades: "Mts", Costo_Unitario: 1434, Lote: 960, Tiempo_Medio: 3.449, Precio_Unitario: 1763, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 32, Descripcion: "Cuero", Tipo: "Materia prima", Grupo: "2", Unidades: "Un", Costo_Unitario: 996, Lote: 230, Tiempo_Medio: 2.834, Precio_Unitario: 1135, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 33, Descripcion: "Seda", Tipo: "Materia prima", Grupo: "5", Unidades: "Kg", Costo_Unitario: 834, Lote: 90, Tiempo_Medio: 0.711, Precio_Unitario: 992, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 34, Descripcion: "Cerveza ", Tipo: "Producto procesado", Grupo: "12", Unidades: "Lts", Costo_Unitario: 1294, Lote: 700, Tiempo_Medio: 1.505, Precio_Unitario: 4538, Sku1: "14", Sku2: "27", Sku3: "", Sku4: ""
  }, {Sku: 35, Descripcion: "Tequila ", Tipo: "Producto procesado", Grupo: "10", Unidades: "Lts", Costo_Unitario: 1435, Lote: 500, Tiempo_Medio: 1.16, Precio_Unitario: 3361, Sku1: "44", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 36, Descripcion: "Papel ", Tipo: "Producto procesado", Grupo: "11", Unidades: "Mts", Costo_Unitario: 1786, Lote: 100, Tiempo_Medio: 3.918, Precio_Unitario: 3968, Sku1: "45", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 37, Descripcion: "Lino", Tipo: "Materia prima", Grupo: "8", Unidades: "Mts", Costo_Unitario: 764, Lote: 1200, Tiempo_Medio: 2.797, Precio_Unitario: 916, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 38, Descripcion: "Semillas Maravilla", Tipo: "Materia prima", Grupo: "4", Unidades: "Kg", Costo_Unitario: 1201, Lote: 30, Tiempo_Medio: 1.805, Precio_Unitario: 1513, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 39, Descripcion: "Uva", Tipo: "Materia prima", Grupo: "7", Unidades: "Kg", Costo_Unitario: 889, Lote: 250, Tiempo_Medio: 3.753, Precio_Unitario: 1217, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 40, Descripcion: "Queso ", Tipo: "Producto procesado", Grupo: "1", Unidades: "Kg", Costo_Unitario: 2324, Lote: 900, Tiempo_Medio: 3.589, Precio_Unitario: 8744, Sku1: "7", Sku2: "41", Sku3: "", Sku4: ""
  }, {Sku: 41, Descripcion: "Suero de Leche", Tipo: "Producto procesado", Grupo: "10", Unidades: "Lts", Costo_Unitario: 1407, Lote: 200, Tiempo_Medio: 3.983, Precio_Unitario: 3148, Sku1: "7", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 42, Descripcion: "Cereal Maíz", Tipo: "Producto procesado", Grupo: "5", Unidades: "Kg", Costo_Unitario: 1949, Lote: 200, Tiempo_Medio: 1.459, Precio_Unitario: 7275, Sku1: "25", Sku2: "20", Sku3: "3", Sku4: ""
  }, {Sku: 43, Descripcion: "Madera", Tipo: "Materia prima", Grupo: "11", Unidades: "Mts3", Costo_Unitario: 1197, Lote: 1000, Tiempo_Medio: 1.27, Precio_Unitario: 1651, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 44, Descripcion: "Agave", Tipo: "Materia prima", Grupo: "4", Unidades: "Kg", Costo_Unitario: 1091, Lote: 50, Tiempo_Medio: 2.56, Precio_Unitario: 1254, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 45, Descripcion: "Celulosa", Tipo: "Materia prima", Grupo: "1", Unidades: "Kg", Costo_Unitario: 1500, Lote: 800, Tiempo_Medio: 0.759, Precio_Unitario: 1695, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 46, Descripcion: "Chocolate", Tipo: "Producto procesado", Grupo: "9", Unidades: "Kg", Costo_Unitario: 2372, Lote: 800, Tiempo_Medio: 1.205, Precio_Unitario: 8514, Sku1: "20", Sku2: "25", Sku3: "7", Sku4: ""
  }, {Sku: 47, Descripcion: "Vino ", Tipo: "Producto procesado", Grupo: "1", Unidades: "Lts", Costo_Unitario: 1921, Lote: 1000, Tiempo_Medio: 0.677, Precio_Unitario: 7244, Sku1: "39", Sku2: "27", Sku3: "15", Sku4: ""
  }, {Sku: 48, Descripcion: "Pasta de Sémola ", Tipo: "Producto procesado", Grupo: "9", Unidades: "Kg", Costo_Unitario: 1652, Lote: 500, Tiempo_Medio: 2.47, Precio_Unitario: 6627, Sku1: "19", Sku2: "26", Sku3: "2", Sku4: ""
  }, {Sku: 49, Descripcion: "Leche Descremada", Tipo: "Producto procesado", Grupo: "3", Unidades: "Lts", Costo_Unitario: 1459, Lote: 200, Tiempo_Medio: 4.281, Precio_Unitario: 3568, Sku1: "7", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 50, Descripcion: "Arroz con Leche", Tipo: "Producto procesado", Grupo: "5", Unidades: "Kg", Costo_Unitario: 1940, Lote: 350, Tiempo_Medio: 4.058, Precio_Unitario: 7266, Sku1: "7", Sku2: "25", Sku3: "13", Sku4: ""
  }, {Sku: 51, Descripcion: "Pan Hallulla", Tipo: "Producto procesado", Grupo: "12", Unidades: "Kg", Costo_Unitario: 2153, Lote: 600, Tiempo_Medio: 1.658, Precio_Unitario: 27701, Sku1: "23", Sku2: "26", Sku3: "22", Sku4: "27"
  }, {Sku: 52, Descripcion: "Harina Integral", Tipo: "Materia prima", Grupo: "5", Unidades: "Kg", Costo_Unitario: 1466, Lote: 890, Tiempo_Medio: 2.13, Precio_Unitario: 1949, Sku1: "", Sku2: "", Sku3: "", Sku4: ""
  }, {Sku: 53, Descripcion: "Pan Integral", Tipo: "Producto procesado", Grupo: "6", Unidades: "Kg", Costo_Unitario: 2632, Lote: 620, Tiempo_Medio: 3.89, Precio_Unitario: 10492, Sku1: "52", Sku2: "26", Sku3: "38", Sku4: "7"
  }, {Sku: 54, Descripcion: "Hamburguesas", Tipo: "Producto procesado", Grupo: "10", Unidades: "Kg", Costo_Unitario: 2190, Lote: 1800, Tiempo_Medio: 4.012, Precio_Unitario: 6314, Sku1: "9", Sku2: "26", Sku3: "", Sku4: ""
  }, {Sku: 55, Descripcion: "Galletas Integrales", Tipo: "Producto procesado", Grupo: "3", Unidades: "Kg", Costo_Unitario: 2284, Lote: 950, Tiempo_Medio: 3.955, Precio_Unitario: 7678, Sku1: "52", Sku2: "20", Sku3: "2", Sku4: ""
  }, {Sku: 56, Descripcion: "Hamburguesas de Pollo", Tipo: "Producto procesado", Grupo: "9", Unidades: "Kg", Costo_Unitario: 2271, Lote: 620, Tiempo_Medio: 2.01, Precio_Unitario: 5052, Sku1: "1", Sku2: "26", Sku3: "", Sku4: ""

  }])
end

p "Existen #{Item.count} items"

if Almacen.count == 0
  p 'No se encontraron almacenes... Sincronizando con servidor'
  Producto.destroy_all
  almacenes = lista_de_almacenes
  almacenes.each do |a|
    p 'Creando almacen...'
    almacen = Almacen.new(_id: a['_id'],
                          espacioTotal: a['totalSpace'],
                          recepcion: a['recepcion'],
                          despacho: a['despacho'],
                          pulmon: a['pulmon'])
    almacen.save!
    productos = productos_almacen(a['_id'])
    productos.each do |pr|
      producto = Producto.new(_id: pr['_id'], sku: pr['sku'], estado: 'disponible')
      producto.almacen = almacen
      producto.save!
    end
  end
end

p "Existen #{Almacen.count} Almacenes y #{Producto.count} Productos"

# Comentar esto una vez ya ejecutado una vez
# Spree::Core::Engine.load_seed if defined?(Spree::Core)
# Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
