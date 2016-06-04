class CreateProducto < ActiveRecord::Migration
  def change
    create_table :productos do |t|
      t.string :_id
      t.integer :sku
      t.string :estado

      t.belongs_to :almacen, index: true
    end
  end
end
