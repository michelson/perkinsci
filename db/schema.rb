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

ActiveRecord::Schema.define(version: 20160210182913) do

  create_table "build_reports", force: :cascade do |t|
    t.string   "sha"
    t.string   "branch"
    t.string   "build_time"
    t.string   "duration"
    t.text     "response"
    t.boolean  "status"
    t.integer  "repo_id"
    t.string   "build_status"
    t.text     "commit"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "build_reports", ["repo_id"], name: "index_build_reports_on_repo_id"

  create_table "repos", force: :cascade do |t|
    t.string   "url"
    t.string   "name"
    t.string   "working_dir"
    t.string   "branch"
    t.integer  "gb_id"
    t.text     "github_data"
    t.boolean  "cached"
    t.string   "build_status"
    t.string   "download_status"
    t.integer  "hook_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
