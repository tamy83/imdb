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

ActiveRecord::Schema.define(version: 20180426062416) do

  create_table "crew_members", force: :cascade do |t|
    t.integer  "person_id",  limit: 4, null: false
    t.integer  "work_id",    limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "crew_members", ["person_id", "work_id"], name: "index_crew_members_on_person_id_and_work_id", unique: true, using: :btree

  create_table "crew_members_roles", id: false, force: :cascade do |t|
    t.integer "crew_member_id", limit: 4, null: false
    t.integer "role_id",        limit: 4, null: false
  end

  add_index "crew_members_roles", ["crew_member_id"], name: "index_crew_members_roles_on_crew_member_id", using: :btree
  add_index "crew_members_roles", ["role_id"], name: "index_crew_members_roles_on_role_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "photo_url",     limit: 255
    t.string   "profile_url",   limit: 255, null: false
    t.string   "work_rankings", limit: 255
    t.date     "birthdate"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "people", ["profile_url"], name: "index_people_on_profile_url", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree

  create_table "works", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.string   "url",        limit: 255,                                     null: false
    t.decimal  "rating",                 precision: 4, scale: 2
    t.integer  "category",   limit: 4,                           default: 0, null: false
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
  end

  add_index "works", ["url"], name: "index_works_on_url", unique: true, using: :btree

  add_foreign_key "crew_members_roles", "crew_members", on_delete: :cascade
  add_foreign_key "crew_members_roles", "roles", on_delete: :cascade
end
