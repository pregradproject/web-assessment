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

ActiveRecord::Schema[8.0].define(version: 2025_07_02_120000) do
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

  create_table "configs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.text "value", null: false
    t.text "description"
    t.string "value_type", default: "string", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_configs_on_key", unique: true
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

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.date "birthday"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "vark_result_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vark_test_id", null: false
    t.uuid "user_id", null: false
    t.integer "min_score", null: false
    t.integer "max_score", null: false
    t.integer "visual_score"
    t.integer "aural_score"
    t.integer "read_score"
    t.integer "kinesthetic_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_vark_result_levels_on_user_id"
    t.index ["vark_test_id"], name: "index_vark_result_levels_on_vark_test_id"
  end

  create_table "vark_test_answers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "vark_test_id", null: false
    t.uuid "vark_question_id", null: false
    t.uuid "vark_category_id", null: false
    t.integer "point", null: false
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
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
end
