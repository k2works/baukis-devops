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

ActiveRecord::Schema.define(version: 20160601060407) do

  create_table "addresses", force: :cascade do |t|
    t.integer  "customer_id",   limit: 4,                null: false
    t.string   "type",          limit: 255,              null: false
    t.string   "postal_code",   limit: 255,              null: false
    t.string   "prefecture",    limit: 255,              null: false
    t.string   "city",          limit: 255,              null: false
    t.string   "address1",      limit: 255,              null: false
    t.string   "address2",      limit: 255,              null: false
    t.string   "company_name",  limit: 255, default: "", null: false
    t.string   "division_name", limit: 255, default: "", null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "addresses", ["customer_id"], name: "index_addresses_on_customer_id", using: :btree
  add_index "addresses", ["type", "customer_id"], name: "index_addresses_on_type_and_customer_id", unique: true, using: :btree

  create_table "administrators", force: :cascade do |t|
    t.string   "email",           limit: 255,                 null: false
    t.string   "email_for_index", limit: 255,                 null: false
    t.string   "hashed_password", limit: 255
    t.boolean  "suspended",                   default: false, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "administrators", ["email_for_index"], name: "index_administrators_on_email_for_index", unique: true, using: :btree

  create_table "customers", force: :cascade do |t|
    t.string   "email",            limit: 255, null: false
    t.string   "email_for_index",  limit: 255, null: false
    t.string   "family_name",      limit: 255, null: false
    t.string   "given_name",       limit: 255, null: false
    t.string   "family_name_kana", limit: 255, null: false
    t.string   "given_name_kana",  limit: 255, null: false
    t.string   "gender",           limit: 255
    t.date     "birthday"
    t.string   "hashed_password",  limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "customers", ["email_for_index"], name: "index_customers_on_email_for_index", unique: true, using: :btree
  add_index "customers", ["family_name_kana", "given_name_kana"], name: "index_customers_on_family_name_kana_and_given_name_kana", using: :btree

  create_table "phones", force: :cascade do |t|
    t.integer  "customer_id",      limit: 4,                   null: false
    t.integer  "address_id",       limit: 4
    t.string   "number",           limit: 255,                 null: false
    t.string   "number_for_index", limit: 255,                 null: false
    t.boolean  "primary",                      default: false, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "phones", ["address_id"], name: "index_phones_on_address_id", using: :btree
  add_index "phones", ["customer_id"], name: "index_phones_on_customer_id", using: :btree
  add_index "phones", ["number_for_index"], name: "index_phones_on_number_for_index", using: :btree

  create_table "staff_events", force: :cascade do |t|
    t.integer  "staff_member_id", limit: 4,   null: false
    t.string   "type",            limit: 255, null: false
    t.datetime "created_at",                  null: false
  end

  add_index "staff_events", ["created_at"], name: "index_staff_events_on_created_at", using: :btree
  add_index "staff_events", ["staff_member_id", "created_at"], name: "index_staff_events_on_staff_member_id_and_created_at", using: :btree

  create_table "staff_members", force: :cascade do |t|
    t.string   "email",            limit: 255,                 null: false
    t.string   "email_for_index",  limit: 255,                 null: false
    t.string   "family_name",      limit: 255,                 null: false
    t.string   "given_name",       limit: 255,                 null: false
    t.string   "family_name_kana", limit: 255,                 null: false
    t.string   "given_name_kana",  limit: 255,                 null: false
    t.string   "hashed_password",  limit: 255
    t.date     "start_date",                                   null: false
    t.date     "end_date"
    t.boolean  "suspended",                    default: false, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "staff_members", ["email_for_index"], name: "index_staff_members_on_email_for_index", unique: true, using: :btree
  add_index "staff_members", ["family_name_kana", "given_name_kana"], name: "index_staff_members_on_family_name_kana_and_given_name_kana", using: :btree

  add_foreign_key "addresses", "customers", name: "addresses_customer_id_fk"
  add_foreign_key "phones", "addresses"
  add_foreign_key "phones", "customers"
  add_foreign_key "staff_events", "staff_members", name: "staff_events_staff_member_id_fk"
end
