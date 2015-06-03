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

ActiveRecord::Schema.define(version: 20150603140756) do

  create_table "activities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "tcx"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "sport"
    t.string   "activity_id"
  end

  add_index "activities", ["user_id"], name: "index_activities_on_user_id"

  create_table "laps", force: :cascade do |t|
    t.integer  "activity_id"
    t.decimal  "total_time_seconds"
    t.decimal  "distance_meters"
    t.decimal  "maximum_speed"
    t.integer  "calories"
    t.integer  "average_heart_rate_bpm"
    t.integer  "maximum_heart_rate_bpm"
    t.string   "intensity"
    t.integer  "cadence"
    t.string   "trigger_method"
    t.string   "notes"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "laps", ["activity_id"], name: "index_laps_on_activity_id"

  create_table "track_points", force: :cascade do |t|
    t.integer  "track_id"
    t.datetime "time"
    t.decimal  "altitude_meters"
    t.decimal  "distance_meters"
    t.integer  "heart_rate_bpm"
    t.string   "sensor_state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "track_points", ["track_id"], name: "index_track_points_on_track_id"

  create_table "tracks", force: :cascade do |t|
    t.integer  "lap_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tracks", ["lap_id"], name: "index_tracks_on_lap_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
  end

end
