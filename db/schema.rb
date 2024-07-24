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

ActiveRecord::Schema[7.1].define(version: 2024_07_22_113326) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "present_id", null: false
    t.string "signature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["present_id"], name: "index_awards_on_present_id"
    t.index ["user_id"], name: "index_awards_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "max_players", default: 10, null: false
    t.integer "max_round_time", default: 90, null: false
    t.integer "max_rounds"
    t.integer "max_points"
    t.string "name", null: false
    t.boolean "viewable", default: true, null: false
    t.boolean "viewers_vote", default: false, null: false
    t.bigint "winner_id"
    t.integer "winner_score"
    t.integer "status", default: 0, null: false
    t.integer "afk_rounds", default: 0, null: false
    t.integer "n_rounds", default: 0, null: false
    t.integer "n_players", default: 0, null: false
    t.integer "n_viewers", default: 0, null: false
    t.bigint "host_id"
    t.string "host_username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host_id"], name: "index_games_on_host_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "jokes", force: :cascade do |t|
    t.string "setup"
    t.string "punchline"
    t.string "text"
    t.integer "n_votes", default: 0
    t.bigint "round_id"
    t.bigint "punchline_author_id"
    t.bigint "setup_author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["punchline_author_id"], name: "index_jokes_on_punchline_author_id"
    t.index ["round_id"], name: "index_jokes_on_round_id"
    t.index ["setup_author_id"], name: "index_jokes_on_setup_author_id"
  end

  create_table "presents", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.boolean "current", default: true
    t.boolean "last", default: false
    t.integer "stage", default: 0
    t.string "setup"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_rounds_on_game_id"
    t.index ["user_id"], name: "index_rounds_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.integer "game_id"
    t.boolean "connected", default: false
    t.boolean "subscribed_to_game", default: false
    t.boolean "host", default: false
    t.boolean "hot_join", default: false
    t.boolean "lead", default: false
    t.boolean "was_lead", default: false
    t.boolean "finished_turn", default: false
    t.boolean "voted", default: false
    t.integer "current_score", default: 0
    t.integer "total_score", default: 0
    t.boolean "show_jokes_allowed", default: true
    t.boolean "show_awards_allowed", default: true
    t.boolean "guest", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "joke_id", null: false
    t.bigint "round_id"
    t.integer "weight", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["joke_id"], name: "index_votes_on_joke_id"
    t.index ["round_id"], name: "index_votes_on_round_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "awards", "presents"
  add_foreign_key "awards", "users"
  add_foreign_key "games", "users", column: "host_id"
  add_foreign_key "games", "users", column: "winner_id"
  add_foreign_key "jokes", "rounds"
  add_foreign_key "jokes", "users", column: "punchline_author_id"
  add_foreign_key "jokes", "users", column: "setup_author_id"
  add_foreign_key "rounds", "games"
  add_foreign_key "rounds", "users"
end
