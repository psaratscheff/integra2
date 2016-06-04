# Single product with _id
class Producto < ActiveRecord::Base
  belongs_to :almacen
end
