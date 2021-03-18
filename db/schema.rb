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

ActiveRecord::Schema.define(version: 20210318113702) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "holidays", id: :bigserial, force: :cascade do |t|
    t.date     "date"
    t.string   "occasion",      limit: 255
    t.bigint   "ooo_config_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "deleted_at"
    t.index ["ooo_config_id"], name: "idx_34146_index_holidays_on_ooo_config_id", using: :btree
  end

  create_table "ooo_configs", id: :bigserial, force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "financial_year",          limit: 255
    t.bigint   "leaves_count"
    t.bigint   "wfhs_count"
    t.bigint   "wfh_penalty_coefficient"
    t.float    "wfh_headsup_hours"
    t.datetime "deleted_at"
    t.date     "start_date"
    t.date     "end_date"
    t.index ["financial_year"], name: "idx_34152_index_ooo_configs_on_financial_year", unique: true, using: :btree
  end

  create_table "ooo_periods", id: :bigserial, force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.bigint   "user_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "google_event_id", limit: 255
    t.string   "type",            limit: 255
    t.datetime "deleted_at"
    t.boolean  "skip_penalty",                default: false
    t.index ["user_id"], name: "idx_34158_index_ooo_periods_on_user_id", using: :btree
  end

  create_table "users", id: :bigserial, force: :cascade do |t|
    t.string   "provider",                 limit: 255
    t.string   "uid",                      limit: 255
    t.string   "name",                     limit: 255
    t.string   "oauth_token",              limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "email",                    limit: 255
    t.boolean  "admin"
    t.date     "joining_date"
    t.bigint   "token_expires_at"
    t.boolean  "active",                               default: true
    t.string   "employee_id",              limit: 255
    t.date     "dob"
    t.date     "leaving_date"
    t.string   "fathers_name",             limit: 255
    t.string   "adhaar_number",            limit: 255
    t.string   "pan_number",               limit: 255
    t.string   "blood_group",              limit: 255
    t.string   "emergency_contact_number", limit: 255
    t.string   "mailing_address",          limit: 255
    t.string   "personal_email",           limit: 255
    t.string   "contact_number",           limit: 255
    t.string   "passport_number",          limit: 255
  end

  create_table "versions", id: :bigserial, force: :cascade do |t|
    t.string   "item_type",  limit: 191, null: false
    t.bigint   "item_id",                null: false
    t.string   "event",      limit: 255, null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "idx_34181_index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "holidays", "ooo_configs", on_update: :restrict, on_delete: :restrict
  add_foreign_key "ooo_periods", "users", on_update: :restrict, on_delete: :restrict
end
