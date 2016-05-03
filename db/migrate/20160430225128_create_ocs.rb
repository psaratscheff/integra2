class CreateOcs < ActiveRecord::Migration
  def change
    create_table :ocs do |t|
      t.string :idoc
      t.string :idfactura
      t.string :estado
      t.string :fechaRecepcion
      t.string :fechaEntrega
      t.string :canal
      t.string :cliente
      t.string :proveedor
      t.integer :sku
      t.integer :cantidad
      t.integer :cantidadDespachada

      t.timestamps null: false
    end
  end
end
