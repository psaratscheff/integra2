class CreateFacturas < ActiveRecord::Migration
  def change
    create_table :facturas do |t|
      t.string :_id
      t.string :proveedor
      t.string :cliente
      t.string :valorTotal
      t.string :estadoPago
      t.string :idoc
      t.string :comentario

      t.timestamps null: false
    end
  end
end
