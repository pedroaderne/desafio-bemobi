# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_11_02_191625) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "payments", force: :cascade do |t|
    t.integer "amount_in_cents"
    t.datetime "created_at", null: false
    t.json "customer"
    t.string "external_id"
    t.json "payment_source"
    t.string "phone_number"
    t.json "product"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "recharges", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_message"
    t.string "external_id"
    t.bigint "payment_id", null: false
    t.string "provider_reference"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_recharges_on_payment_id"
  end

  add_foreign_key "recharges", "payments"
end
