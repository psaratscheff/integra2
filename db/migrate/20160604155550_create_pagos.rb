class CreatePagos < ActiveRecord::Migration
  def change
    create_table :pagos do |t|
      t.string :_id
      t.string :cuentaOrigen
      t.string :cuentaDestino
      t.integer :monto

      t.timestamps null: false
    end
  end
end
