# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_200_628_170_531) do

  create_table 'admins', options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8', force: :cascade do |t|
    t.string('email', default: '', null: false)
    t.string('encrypted_password', default: '', null: false)
    t.string('reset_password_token')
    t.datetime('reset_password_sent_at')
    t.datetime('remember_created_at')
    t.datetime('created_at', null: false)
    t.datetime('updated_at', null: false)
    t.index(['email'], name: 'index_admins_on_email', unique: true)
    t.index(['reset_password_token'], name: 'index_admins_on_reset_password_token', unique: true)
  end

  create_table 'merchants', options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8', force: :cascade do |t|
    t.string('name', null: false)
    t.text('description')
    t.string('email', null: false)
    t.enum('status', limit: [:active, :inactive], default: :active, null: false)
    t.decimal('total_transaction_sum', precision: 10, default: '0', null: false)
    t.string('encrypted_password', default: '', null: false)
    t.datetime('created_at', null: false)
    t.datetime('updated_at', null: false)
    t.index(['email'], name: 'index_merchants_on_email', unique: true)
  end

  create_table 'payment_transactions', options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8', force: :cascade do |t|
    t.string('uuid', limit: 36, null: false)
    t.bigint('merchant_id', null: false)
    t.bigint('payment_transaction_id')
    t.enum('status', limit: [:approved, :reversed, :refunded, :error], null: false)
    t.enum('type', limit: [:AuthorizeTransaction, :ChargeTransaction, :RefundTransaction, :ReversalTransaction], null: false)
    t.decimal('amount', precision: 10)
    t.string('customer_email')
    t.string('customer_phone')
    t.datetime('created_at', null: false)
    t.datetime('updated_at', null: false)
    t.index(['merchant_id'], name: 'fk_rails_63c2dffe82')
    t.index(['payment_transaction_id'], name: 'fk_rails_cd4c2d6004')
    t.index(['uuid'], name: 'index_payment_transactions_on_uuid', unique: true)
  end

  add_foreign_key 'payment_transactions', 'merchants'
  add_foreign_key 'payment_transactions', 'payment_transactions'
end
