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

ActiveRecord::Schema[7.0].define(version: 2023_10_31_220501) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "committees", force: :cascade do |t|
    t.bigint "council_id", null: false
    t.text "name"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["council_id"], name: "index_committees_on_council_id"
  end

  create_table "councils", force: :cascade do |t|
    t.text "name"
    t.text "external_id"
    t.text "base_scrape_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "meeting_id", null: false
    t.text "name"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "text"
    t.text "extract_status", default: "pending", null: false
    t.index ["meeting_id"], name: "index_documents_on_meeting_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.bigint "council_id", null: false
    t.bigint "committee_id"
    t.text "name"
    t.text "url"
    t.text "notes"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["committee_id"], name: "index_meetings_on_committee_id"
    t.index ["council_id"], name: "index_meetings_on_council_id"
    t.index ["date"], name: "index_meetings_on_date"
  end

  create_table "people", force: :cascade do |t|
    t.bigint "council_id", null: false
    t.text "name"
    t.text "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["council_id"], name: "index_people_on_council_id"
  end

  add_foreign_key "committees", "councils"
  add_foreign_key "documents", "meetings"
  add_foreign_key "meetings", "committees"
  add_foreign_key "meetings", "councils"
  add_foreign_key "people", "councils"
end
