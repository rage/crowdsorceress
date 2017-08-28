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

ActiveRecord::Schema.define(version: 20170828134428) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.text "description"
    t.bigint "exercise_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_type_id"], name: "index_assignments_on_exercise_type_id"
  end

  create_table "exercise_types", force: :cascade do |t|
    t.string "name"
    t.text "test_template"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "code_template", default: "", null: false
  end

  create_table "exercises", force: :cascade do |t|
    t.bigint "user_id"
    t.text "code"
    t.bigint "assignment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "testIO"
    t.json "description"
    t.integer "status", default: 0
    t.text "sandbox_results"
    t.integer "peer_reviews_count", default: 0
    t.text "model_solution"
    t.text "template"
    t.json "error_messages", default: [], array: true
    t.integer "times_sent_to_sandbox", default: 0, null: false
    t.integer "submit_count", default: 0, null: false
    t.index ["assignment_id"], name: "index_exercises_on_assignment_id"
    t.index ["user_id"], name: "index_exercises_on_user_id"
  end

  create_table "exercises_tags", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "exercise_id"
    t.index ["exercise_id"], name: "index_exercises_tags_on_exercise_id"
    t.index ["tag_id"], name: "index_exercises_tags_on_tag_id"
  end

  create_table "peer_review_question_answers", force: :cascade do |t|
    t.integer "grade", null: false
    t.bigint "peer_review_id"
    t.bigint "peer_review_question_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["peer_review_id"], name: "index_peer_review_question_answers_on_peer_review_id"
    t.index ["peer_review_question_id"], name: "index_peer_review_question_answers_on_peer_review_question_id"
  end

  create_table "peer_review_questions", force: :cascade do |t|
    t.string "question", null: false
    t.bigint "exercise_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_type_id"], name: "index_peer_review_questions_on_exercise_type_id"
  end

  create_table "peer_reviews", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "exercise_id"
    t.text "comment", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exercise_id"], name: "index_peer_reviews_on_exercise_id"
    t.index ["user_id"], name: "index_peer_reviews_on_user_id"
  end

  create_table "peer_reviews_tags", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "peer_review_id"
    t.index ["peer_review_id"], name: "index_peer_reviews_tags_on_peer_review_id"
    t.index ["tag_id"], name: "index_peer_reviews_tags_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "recommended", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.boolean "administrator"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "last_logged_in"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "assignments", "exercise_types"
  add_foreign_key "exercises_tags", "exercises"
  add_foreign_key "exercises_tags", "tags"
  add_foreign_key "peer_review_question_answers", "peer_review_questions"
  add_foreign_key "peer_review_question_answers", "peer_reviews"
  add_foreign_key "peer_review_questions", "exercise_types"
  add_foreign_key "peer_reviews", "exercises"
  add_foreign_key "peer_reviews", "users"
  add_foreign_key "peer_reviews_tags", "peer_reviews"
  add_foreign_key "peer_reviews_tags", "tags"
end
