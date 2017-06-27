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

ActiveRecord::Schema.define(version: 20170622142403) do

  create_table "holidays", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "date"
    t.string   "occasion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ooo_configs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "financial_year"
    t.integer  "leaves_count"
    t.integer  "wfhs_count"
    t.index ["financial_year"], name: "index_ooo_configs_on_financial_year", unique: true, using: :btree
  end

  create_table "ooo_periods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.float    "number_of_days",  limit: 24
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "google_event_id"
    t.string   "type"
    t.index ["user_id"], name: "index_ooo_periods_on_user_id", using: :btree
  end

  create_table "ooo_periods_infos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "financial_year"
    t.integer  "remaining_leaves"
    t.integer  "total_leaves"
    t.text     "total_wfhs",       limit: 65535
    t.text     "remaining_wfhs",   limit: 65535
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["financial_year", "user_id"], name: "index_ooo_periods_infos_on_financial_year_and_user_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_ooo_periods_infos_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "email"
    t.integer  "remaining_leaves"
    t.integer  "total_leaves"
    t.boolean  "admin"
    t.date     "joining_date"
    t.integer  "token_expires_at"
    t.integer  "total_wfhs"
    t.integer  "remaining_wfhs"
  end

  add_foreign_key "ooo_periods", "users"
  add_foreign_key "ooo_periods_infos", "users"
end
