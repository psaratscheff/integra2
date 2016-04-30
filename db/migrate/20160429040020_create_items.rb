class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :Sku
      t.string :Descripcion
      t.string :Tipo
      t.string :Grupo
      t.string :Unidades
      t.integer :Costo_Unitario
      t.integer :Lote
      t.float :Tiempo_Medio
      t.integer :Precio_Unitario
      t.string :Sku1
      t.string :Sku2
      t.string :Sku3
      t.string :Sku4

      t.timestamps null: false
    end
  end
end
