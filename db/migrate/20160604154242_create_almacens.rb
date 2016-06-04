class CreateAlmacens < ActiveRecord::Migration
  def change
    create_table :almacens do |t|
      t.boolean :pulmon
      t.boolean :despacho
      t.boolean :recepcion
      t.integer :espacioTotal
      t.integer :espacioUtilizado
      t.string :_id

      t.timestamps null: false
    end
  end
end
