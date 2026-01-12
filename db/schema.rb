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

ActiveRecord::Schema[8.0].define(version: 2026_01_12_172947) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "email_events", force: :cascade do |t|
    t.string "kind", null: false
    t.bigint "request_id"
    t.bigint "recipient_id", null: false
    t.datetime "sent_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "request_id", "recipient_id", "sent_at"], name: "index_email_events_on_kind_request_recipient_sent_at"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.boolean "system", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_messages_on_request_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "parent_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.string "zip_code"
    t.string "city"
    t.string "profile_image_url"
    t.boolean "profile_completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.index ["user_id"], name: "index_parent_profiles_on_user_id", unique: true
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "teacher_id", null: false
    t.string "status", default: "pending", null: false
    t.string "subject", null: false
    t.string "level", null: false
    t.string "request_text", null: false
    t.datetime "requested_at", null: false
    t.datetime "responded_at"
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "student_id"
    t.text "notes"
    t.boolean "archived_by_parent", default: false, null: false
    t.boolean "archived_by_teacher", default: false, null: false
    t.datetime "parent_last_read_at"
    t.datetime "teacher_last_read_at"
    t.index ["parent_id"], name: "index_requests_on_parent_id"
    t.index ["student_id"], name: "index_requests_on_student_id"
    t.index ["teacher_id"], name: "index_requests_on_teacher_id"
  end

  create_table "students", force: :cascade do |t|
    t.bigint "parent_profile_id", null: false
    t.string "first_name"
    t.integer "birth_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_profile_id"], name: "index_students_on_parent_profile_id"
  end

  create_table "teacher_documents", force: :cascade do |t|
    t.bigint "teacher_id", null: false
    t.string "file_url", null: false
    t.string "file_type", null: false
    t.string "original_filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "public_id"
    t.string "cloudinary_resource_type"
    t.string "cloudinary_format"
    t.index ["teacher_id"], name: "index_teacher_documents_on_teacher_id"
  end

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
    t.boolean "picture_visible", default: false, null: false
    t.string "address"
    t.string "zip_code"
    t.string "city"
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
    t.boolean "email_notifications_enabled", default: true, null: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "email_events", "requests", on_delete: :cascade
  add_foreign_key "email_events", "users", column: "recipient_id"
  add_foreign_key "messages", "requests"
  add_foreign_key "messages", "users"
  add_foreign_key "parent_profiles", "users"
  add_foreign_key "requests", "students"
  add_foreign_key "requests", "teachers"
  add_foreign_key "requests", "users", column: "parent_id"
  add_foreign_key "students", "parent_profiles"
  add_foreign_key "teacher_documents", "teachers"
  add_foreign_key "teachers", "users"
end
