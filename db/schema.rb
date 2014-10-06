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

ActiveRecord::Schema.define(version: 20141006105603) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academic_levels", force: true do |t|
    t.string   "name",             limit: 100
    t.integer  "question_type_id"
    t.boolean  "published"
    t.integer  "ussd_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", force: true do |t|
    t.string   "msisdn",            limit: 16
    t.integer  "subscription_id"
    t.integer  "academic_level_id"
    t.integer  "points"
    t.integer  "right_answers"
    t.integer  "wrong_answers"
    t.integer  "current_question"
    t.integer  "participations"
    t.boolean  "published"
    t.date     "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "daily_count"
  end

  add_index "accounts", ["academic_level_id"], name: "index_accounts_on_academic_level_id", using: :btree
  add_index "accounts", ["msisdn"], name: "index_accounts_on_msisdn", using: :btree
  add_index "accounts", ["subscription_id"], name: "index_accounts_on_subscription_id", using: :btree

  create_table "answers", force: true do |t|
    t.string   "message"
    t.integer  "gaming_session_id"
    t.integer  "question_id"
    t.boolean  "correct"
    t.integer  "points"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transaction_id"
    t.boolean  "billed"
  end

  create_table "gaming_sessions", force: true do |t|
    t.integer  "account_id"
    t.integer  "subscription_id"
    t.integer  "question_type_id"
    t.integer  "academic_level_id"
    t.boolean  "unpublished"
    t.datetime "unpublished_at"
    t.integer  "points"
    t.integer  "right_answers"
    t.integer  "wrong_answers"
    t.date     "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_id"
  end

  add_index "gaming_sessions", ["academic_level_id"], name: "index_gaming_sessions_on_academic_level_id", using: :btree
  add_index "gaming_sessions", ["account_id"], name: "index_gaming_sessions_on_account_id", using: :btree
  add_index "gaming_sessions", ["question_type_id"], name: "index_gaming_sessions_on_question_type_id", using: :btree
  add_index "gaming_sessions", ["subscription_id"], name: "index_gaming_sessions_on_subscription_id", using: :btree

  create_table "parameters", force: true do |t|
    t.string   "outgoing_sms_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "billing_url"
  end

  create_table "question_types", force: true do |t|
    t.string   "name",       limit: 100
    t.boolean  "published"
    t.integer  "ussd_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", force: true do |t|
    t.text     "wording"
    t.text     "answer"
    t.integer  "points"
    t.integer  "academic_level_id"
    t.integer  "question_type_id"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.string   "name",       limit: 100
    t.integer  "duration"
    t.integer  "price"
    t.integer  "ussd_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
