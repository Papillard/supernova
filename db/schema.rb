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

ActiveRecord::Schema[8.0].define(version: 2025_11_25_123703) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "teachers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "display_name", null: false
    t.string "gender", null: false
    t.string "academy_name"
    t.string "school_name"
    t.string "career_status", null: false
    t.text "levels", default: [], array: true
    t.text "subjects_tags", default: [], array: true
    t.text "teaching_formats", default: [], array: true
    t.string "base_city"
    t.string "base_zip_code"
    t.string "radius_text"
    t.text "support_text"
    t.text "experience_text"
    t.text "special_skills_text"
    t.text "interest_text"
    t.text "exams_raw_text"
    t.text "exam_tags", default: [], array: true
    t.text "pedagogy_tags", default: [], array: true
    t.text "pricing_text"
    t.string "target_students_range"
    t.string "email_pro", null: false
    t.string "email_perso"
    t.string "phone"
    t.string "profile_image_url"
    t.boolean "profile_image_attached", default: false, null: false
    t.string "status", default: "pending", null: false
    t.boolean "rgpd_consent", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_teachers_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role", default: "parent", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "teachers", "users"
end
