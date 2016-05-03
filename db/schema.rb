# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160501152315) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", primary_key: "Sku", force: :cascade do |t|
    t.string   "Descripcion"
    t.string   "Tipo"
    t.string   "Grupo"
    t.string   "Unidades"
    t.integer  "Costo_Unitario"
    t.integer  "Lote"
    t.float    "Tiempo_Medio"
    t.integer  "Precio_Unitario"
    t.string   "Sku1"
    t.string   "Sku2"
    t.string   "Sku3"
    t.string   "Sku4"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "ocs", force: :cascade do |t|
    t.string   "idoc"
    t.string   "idfactura"
    t.string   "estado"
    t.string   "fechaRecepcion"
    t.string   "fechaEntrega"
    t.string   "canal"
    t.string   "cliente"
    t.string   "proveedor"
    t.integer  "sku"
    t.integer  "cantidad"
    t.integer  "cantidadDespachada"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

end
