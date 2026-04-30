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

ActiveRecord::Schema[8.1].define(version: 2026_04_30_000248) do
  create_table "games", force: :cascade do |t|
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.datetime "ended_at"
    t.bigint "host_player_id"
    t.datetime "last_activity_at"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_games_on_code", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.integer "game_id", null: false
    t.datetime "last_seen_at"
    t.datetime "left_at"
    t.string "name", null: false
    t.string "session_token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["session_token"], name: "index_players_on_session_token", unique: true
  end

  add_foreign_key "players", "games"
end
