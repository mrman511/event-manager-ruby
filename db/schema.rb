# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_28_220602) do
  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "tagline"
    t.text "description"
    t.text "postscript"
    t.datetime "starts"
    t.datetime "ends"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "host_id"
    t.index ["host_id"], name: "index_events_on_host_id"
  end

  create_table "hostings", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "host_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host_id"], name: "index_hostings_on_host_id"
    t.index ["user_id"], name: "index_hostings_on_user_id"
  end

  create_table "hosts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "todos", force: :cascade do |t|
    t.string "title"
    t.string "status"
    t.boolean "is_completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "events", "hosts"
  add_foreign_key "hostings", "hosts"
  add_foreign_key "hostings", "users"
end
