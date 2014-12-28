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

ActiveRecord::Schema.define(version: 20141228233133) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "day_ticker_logs", force: :cascade do |t|
    t.date     "log_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "securities", force: :cascade do |t|
    t.string   "symbol"
    t.string   "company_name"
    t.text     "company_profile"
    t.integer  "board_lot"
    t.decimal  "last_price",           precision: 8, scale: 3
    t.decimal  "volume_traded"
    t.decimal  "open_price",           precision: 8, scale: 3
    t.decimal  "high_price",           precision: 8, scale: 3
    t.decimal  "low_price",            precision: 8, scale: 3
    t.decimal  "previous_close",       precision: 8, scale: 3
    t.float    "percent_change_close"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "ticker_logs", force: :cascade do |t|
    t.datetime "ticker_as_of"
    t.text     "ticker_json"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "day_ticker_log_id"
  end

  add_index "ticker_logs", ["day_ticker_log_id"], name: "index_ticker_logs_on_day_ticker_log_id", using: :btree
  add_index "ticker_logs", ["ticker_as_of"], name: "index_ticker_logs_on_ticker_as_of", unique: true, using: :btree

end
