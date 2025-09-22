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

ActiveRecord::Schema[8.0].define(version: 2025_09_22_143054) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "ai_knowledge_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", limit: 2, null: false
    t.string "name"
    t.string "description"
    t.string "result_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ai_knowledge_categories_on_code", unique: true
  end

  create_table "ai_knowledge_question_set_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ai_knowledge_question_set_id", null: false
    t.uuid "ai_knowledge_category_id", null: false
    t.integer "time_limit_secs", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_knowledge_category_id"], name: "idx_on_ai_knowledge_category_id_09e4d8da87"
    t.index ["ai_knowledge_question_set_id"], name: "idx_on_ai_knowledge_question_set_id_564fcefc03"
  end

  create_table "ai_knowledge_question_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "version", null: false
    t.string "name"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_limit", default: 0, null: false
  end

  create_table "ai_knowledge_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ai_knowledge_question_set_id", null: false
    t.uuid "ai_knowledge_category_id", null: false
    t.text "body", null: false
    t.integer "max_weight", default: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_knowledge_category_id"], name: "index_ai_knowledge_questions_on_ai_knowledge_category_id"
    t.index ["ai_knowledge_question_set_id"], name: "index_ai_knowledge_questions_on_ai_knowledge_question_set_id"
  end

  create_table "ai_knowledge_result_descriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "combination_pattern", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.text "characteristics"
    t.text "study_recommendations"
    t.text "strengths"
    t.text "potential_challenges"
    t.text "career_suggestions"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["combination_pattern"], name: "index_ai_knowledge_result_descriptions_on_combination_pattern", unique: true
  end

  create_table "ai_knowledge_result_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ai_knowledge_test_id", null: false
    t.uuid "user_id", null: false
    t.decimal "min_score", precision: 6, scale: 1, null: false
    t.decimal "max_score", precision: 6, scale: 1, null: false
    t.decimal "performance_expectancy_score", precision: 6, scale: 1
    t.decimal "effort_expectancy_score", precision: 6, scale: 1
    t.decimal "social_influence_score", precision: 6, scale: 1
    t.decimal "facilitating_conditions_score", precision: 6, scale: 1
    t.decimal "hedonic_motivation_score", precision: 6, scale: 1
    t.decimal "price_value_score", precision: 6, scale: 1
    t.decimal "habit_score", precision: 6, scale: 1
    t.decimal "behavioral_intention_score", precision: 6, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_knowledge_test_id"], name: "index_ai_knowledge_result_levels_on_ai_knowledge_test_id"
    t.index ["user_id"], name: "index_ai_knowledge_result_levels_on_user_id"
  end

  create_table "ai_knowledge_test_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ai_knowledge_test_id", null: false
    t.uuid "ai_knowledge_question_id", null: false
    t.uuid "ai_knowledge_category_id", null: false
    t.decimal "point", precision: 4, scale: 1, null: false
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_knowledge_category_id"], name: "index_ai_knowledge_test_answers_on_ai_knowledge_category_id"
    t.index ["ai_knowledge_question_id"], name: "index_ai_knowledge_test_answers_on_ai_knowledge_question_id"
    t.index ["ai_knowledge_test_id"], name: "index_ai_knowledge_test_answers_on_ai_knowledge_test_id"
  end

  create_table "ai_knowledge_tests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "ai_knowledge_question_set_id", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_knowledge_question_set_id"], name: "index_ai_knowledge_tests_on_ai_knowledge_question_set_id"
    t.index ["user_id"], name: "index_ai_knowledge_tests_on_user_id"
  end

  create_table "behavioral_learning_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", limit: 1, null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_behavioral_learning_categories_on_code", unique: true
  end

  create_table "behavioral_learning_question_set_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "behavioral_learning_question_set_id", null: false
    t.uuid "behavioral_learning_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["behavioral_learning_category_id"], name: "idx_on_behavioral_learning_category_id_07ba891428"
    t.index ["behavioral_learning_question_set_id", "behavioral_learning_category_id"], name: "index_bl_question_set_categories_on_set_and_category", unique: true
    t.index ["behavioral_learning_question_set_id"], name: "idx_on_behavioral_learning_question_set_id_4b8b562ad5"
  end

  create_table "behavioral_learning_question_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "version", null: false
    t.boolean "active", default: false
    t.integer "time_limit", default: 1800
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_behavioral_learning_question_sets_on_active"
  end

  create_table "behavioral_learning_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "behavioral_learning_question_set_id", null: false
    t.uuid "behavioral_learning_category_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["behavioral_learning_category_id"], name: "idx_on_behavioral_learning_category_id_7a15636cb9"
    t.index ["behavioral_learning_question_set_id"], name: "idx_on_behavioral_learning_question_set_id_fe386e2b40"
  end

  create_table "behavioral_learning_result_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "behavioral_learning_test_id", null: false
    t.uuid "user_id", null: false
    t.integer "total_score", null: false
    t.integer "total_questions", null: false
    t.decimal "average_score", precision: 5, scale: 2, null: false
    t.string "level_label", null: false
    t.text "level_message", null: false
    t.decimal "threshold_min", precision: 5, scale: 2, null: false
    t.decimal "threshold_max", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["behavioral_learning_test_id"], name: "idx_on_behavioral_learning_test_id_bc00cfbe1a", unique: true
    t.index ["user_id"], name: "index_behavioral_learning_result_levels_on_user_id"
  end

  create_table "behavioral_learning_test_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "behavioral_learning_test_id", null: false
    t.uuid "behavioral_learning_question_id", null: false
    t.uuid "behavioral_learning_category_id", null: false
    t.integer "point", null: false
    t.datetime "answered_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["behavioral_learning_category_id"], name: "idx_on_behavioral_learning_category_id_f8cd56b199"
    t.index ["behavioral_learning_question_id"], name: "idx_on_behavioral_learning_question_id_0ebd6f0b95"
    t.index ["behavioral_learning_test_id", "behavioral_learning_question_id"], name: "index_bl_test_answers_on_test_and_question", unique: true
    t.index ["behavioral_learning_test_id"], name: "idx_on_behavioral_learning_test_id_e14b4f7bf9"
    t.check_constraint "point >= 1 AND point <= 5", name: "bl_point_range_check"
  end

  create_table "behavioral_learning_tests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "behavioral_learning_question_set_id", null: false
    t.integer "status", default: 0
    t.datetime "started_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["behavioral_learning_question_set_id"], name: "idx_on_behavioral_learning_question_set_id_eb0c9740b9"
    t.index ["status"], name: "index_behavioral_learning_tests_on_status"
    t.index ["user_id", "created_at"], name: "index_behavioral_learning_tests_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_behavioral_learning_tests_on_user_id"
  end

  create_table "behavioral_learning_threshold_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label", null: false
    t.text "message", null: false
    t.decimal "min_threshold", precision: 5, scale: 2, null: false
    t.decimal "max_threshold", precision: 5, scale: 2, null: false
    t.integer "priority", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_behavioral_learning_threshold_levels_on_active"
    t.index ["priority"], name: "index_behavioral_learning_threshold_levels_on_priority", unique: true
  end

  create_table "configs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.text "value", null: false
    t.text "description"
    t.string "value_type", default: "string", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_configs_on_key", unique: true
  end

  create_table "coupon_usages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "coupon_id", null: false
    t.uuid "order_id", null: false
    t.datetime "used_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["coupon_id", "used_at"], name: "index_coupon_usages_on_coupon_id_and_used_at"
    t.index ["coupon_id"], name: "index_coupon_usages_on_coupon_id"
    t.index ["order_id"], name: "index_coupon_usages_on_order_id", unique: true
    t.index ["user_id", "coupon_id"], name: "index_coupon_usages_on_user_id_and_coupon_id"
    t.index ["user_id"], name: "index_coupon_usages_on_user_id"
  end

  create_table "coupons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "discount_type", null: false
    t.decimal "discount_value", precision: 10, scale: 2, null: false
    t.datetime "expiry_date"
    t.integer "max_uses_per_user", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active", "expiry_date"], name: "index_coupons_on_active_and_expiry_date"
    t.index ["active"], name: "index_coupons_on_active"
    t.index ["code"], name: "index_coupons_on_code", unique: true
    t.index ["expiry_date"], name: "index_coupons_on_expiry_date"
  end

  create_table "orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "testable_type", null: false
    t.uuid "testable_id", null: false
    t.string "order_number", null: false
    t.integer "category", default: 0, null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.datetime "expires_at"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "certificate_generated_at"
    t.integer "certificate_status", default: 0
    t.text "certificate_generation_error"
    t.decimal "coupon_discount_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "original_amount", precision: 10, scale: 2
    t.decimal "final_amount", precision: 10, scale: 2
    t.uuid "coupon_id"
    t.index ["certificate_status"], name: "index_orders_on_certificate_status"
    t.index ["coupon_id"], name: "index_orders_on_coupon_id"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["status"], name: "index_orders_on_status"
    t.index ["testable_type", "testable_id"], name: "index_orders_on_testable"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "order_id", null: false
    t.string "payment_method"
    t.string "midtrans_transaction_id"
    t.string "midtrans_order_id"
    t.string "snap_token"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.text "midtrans_response"
    t.datetime "paid_at"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["midtrans_order_id"], name: "index_payments_on_midtrans_order_id"
    t.index ["midtrans_transaction_id"], name: "index_payments_on_midtrans_transaction_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["status"], name: "index_payments_on_status"
  end

  create_table "signatures", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "department", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.date "birthday"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_id"
    t.string "auth_provider", default: "email"
    t.string "google_email"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["auth_provider"], name: "index_users_on_auth_provider"
    t.index ["google_email"], name: "index_users_on_google_email"
    t.index ["google_id"], name: "index_users_on_google_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vark_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", limit: 1, null: false
    t.string "name"
    t.string "description"
    t.string "result_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_vark_categories_on_code", unique: true
  end

  create_table "vark_question_set_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vark_question_set_id", null: false
    t.uuid "vark_category_id", null: false
    t.integer "time_limit_secs", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vark_category_id"], name: "index_vark_question_set_categories_on_vark_category_id"
    t.index ["vark_question_set_id"], name: "index_vark_question_set_categories_on_vark_question_set_id"
  end

  create_table "vark_question_sets", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "version", null: false
    t.string "name"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "time_limit", default: 0, null: false
  end

  create_table "vark_questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vark_question_set_id", null: false
    t.uuid "vark_category_id", null: false
    t.text "body", null: false
    t.integer "max_weight", default: 5, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vark_category_id"], name: "index_vark_questions_on_vark_category_id"
    t.index ["vark_question_set_id"], name: "index_vark_questions_on_vark_question_set_id"
  end

  create_table "vark_result_descriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "combination_pattern", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.text "characteristics"
    t.text "study_recommendations"
    t.text "strengths"
    t.text "potential_challenges"
    t.text "career_suggestions"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["combination_pattern"], name: "index_vark_result_descriptions_on_combination_pattern", unique: true
  end

  create_table "vark_result_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vark_test_id", null: false
    t.uuid "user_id", null: false
    t.decimal "min_score", precision: 6, scale: 1, null: false
    t.decimal "max_score", precision: 6, scale: 1, null: false
    t.decimal "visual_score", precision: 6, scale: 1
    t.decimal "aural_score", precision: 6, scale: 1
    t.decimal "read_score", precision: 6, scale: 1
    t.decimal "kinesthetic_score", precision: 6, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vark_result_levels_on_user_id"
    t.index ["vark_test_id"], name: "index_vark_result_levels_on_vark_test_id"
  end

  create_table "vark_test_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vark_test_id", null: false
    t.uuid "vark_question_id", null: false
    t.uuid "vark_category_id", null: false
    t.decimal "point", precision: 4, scale: 1, null: false
    t.datetime "answered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vark_category_id"], name: "index_vark_test_answers_on_vark_category_id"
    t.index ["vark_question_id"], name: "index_vark_test_answers_on_vark_question_id"
    t.index ["vark_test_id"], name: "index_vark_test_answers_on_vark_test_id"
  end

  create_table "vark_tests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "vark_question_set_id", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vark_tests_on_user_id"
    t.index ["vark_question_set_id"], name: "index_vark_tests_on_vark_question_set_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "behavioral_learning_question_set_categories", "behavioral_learning_categories"
  add_foreign_key "behavioral_learning_question_set_categories", "behavioral_learning_question_sets"
  add_foreign_key "behavioral_learning_questions", "behavioral_learning_categories"
  add_foreign_key "behavioral_learning_questions", "behavioral_learning_question_sets"
  add_foreign_key "behavioral_learning_result_levels", "behavioral_learning_tests"
  add_foreign_key "behavioral_learning_result_levels", "users"
  add_foreign_key "behavioral_learning_test_answers", "behavioral_learning_categories"
  add_foreign_key "behavioral_learning_test_answers", "behavioral_learning_questions"
  add_foreign_key "behavioral_learning_test_answers", "behavioral_learning_tests"
  add_foreign_key "behavioral_learning_tests", "behavioral_learning_question_sets"
  add_foreign_key "behavioral_learning_tests", "users"
  add_foreign_key "coupon_usages", "coupons"
  add_foreign_key "coupon_usages", "orders"
  add_foreign_key "coupon_usages", "users"
  add_foreign_key "orders", "coupons"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
