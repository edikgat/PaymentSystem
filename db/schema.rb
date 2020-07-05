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

ActiveRecord::Schema.define(version: 2020_06_28_170531) do

  create_table "admins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "merchants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "email", null: false
    t.enum "status", limit: [:active, :inactive], default: :active, null: false
    t.decimal "total_transaction_sum", precision: 10, default: "0", null: false
    t.string "encrypted_password", default: "", null: false
    t.bigint "lock_version", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "payment_transactions_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_merchants_on_email", unique: true
    t.index ["reset_password_token"], name: "index_merchants_on_reset_password_token", unique: true
  end

  create_table "payment_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "uuid", limit: 36, null: false
    t.bigint "merchant_id", null: false
    t.bigint "parent_payment_transaction_id"
    t.enum "status", limit: [:approved, :reversed, :refunded, :error], default: :approved, null: false
    t.enum "type", limit: [:AuthorizeTransaction, :ChargeTransaction, :RefundTransaction, :ReversalTransaction], null: false
    t.decimal "amount", precision: 10
    t.string "customer_email"
    t.string "customer_phone"
    t.integer "lock_version", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "fk_rails_63c2dffe82"
    t.index ["parent_payment_transaction_id"], name: "fk_rails_41d0b0da7b"
    t.index ["uuid"], name: "index_payment_transactions_on_uuid", unique: true
  end

  add_foreign_key "payment_transactions", "merchants"
  add_foreign_key "payment_transactions", "payment_transactions", column: "parent_payment_transaction_id"
end
