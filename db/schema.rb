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

ActiveRecord::Schema[8.1].define(version: 2026_03_20_081447) do
  create_table "access_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration"
    t.datetime "entered_at"
    t.datetime "exited_at"
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.integer "web_access_key_id", null: false
    t.index ["web_access_key_id"], name: "index_access_logs_on_web_access_key_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "password_digest"
    t.string "remember_token"
    t.datetime "updated_at", null: false
    t.index ["remember_token"], name: "index_admins_on_remember_token", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "key"
    t.string "key_type", default: "web_access", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_api_keys_on_key", unique: true
  end

  create_table "project_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "file_type"
    t.integer "project_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_files_on_project_id"
  end

  create_table "project_keys", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "key"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "project_views", force: :cascade do |t|
    t.integer "access_log_id", null: false
    t.datetime "created_at", null: false
    t.integer "project_id", null: false
    t.datetime "updated_at", null: false
    t.datetime "viewed_at", null: false
    t.index ["access_log_id"], name: "index_project_views_on_access_log_id"
    t.index ["project_id"], name: "index_project_views_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "customer"
    t.text "description"
    t.string "name"
    t.string "sku"
    t.datetime "updated_at", null: false
    t.integer "updates_count", default: 0, null: false
    t.index ["sku"], name: "index_projects_on_sku", unique: true
  end

  create_table "web_access_keys", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "key"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "access_logs", "web_access_keys"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "project_files", "projects"
  add_foreign_key "project_views", "access_logs"
  add_foreign_key "project_views", "projects"
end
