# Model for every Almacen type
class Almacen < ActiveRecord::Base
  has_many :productos
end
