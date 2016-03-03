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

ActiveRecord::Schema.define(version: 20160225220247) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "survey_tokens", force: :cascade do |t|
    t.string "survey_id"
    t.string "token"
  end

  add_index "survey_tokens", ["token"], name: "index_survey_tokens_on_token", unique: true, using: :btree

  create_table "tallies", force: :cascade do |t|
    t.string   "field",      limit: 1024,             null: false
    t.string   "value",      limit: 1024,             null: false
    t.integer  "count",                   default: 0, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "survey_id"
  end

  add_index "tallies", ["field", "value", "survey_id"], name: "index_tallies_on_field_and_value_and_survey_id", unique: true, using: :btree

end
