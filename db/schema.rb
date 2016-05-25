# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160525170649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "interests", force: :cascade do |t|
    t.datetime "watched_on"
    t.integer  "user_id"
    t.integer  "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "interests", ["movie_id"], name: "index_interests_on_movie_id", using: :btree
  add_index "interests", ["user_id"], name: "index_interests_on_user_id", using: :btree

  create_table "movies", force: :cascade do |t|
    t.string   "title"
    t.string   "original_title"
    t.integer  "runtime"
    t.string   "tagline"
    t.string   "genre"
    t.text     "credits"
    t.string   "poster_url"
    t.string   "trailer_url"
    t.string   "website_url"
    t.string   "imdb_id"
    t.string   "cnc_url"
    t.integer  "tmdb_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "adult"
    t.integer  "budget"
    t.string   "genres"
    t.text     "overview"
    t.float    "popularity"
    t.string   "original_language"
    t.string   "poster_path"
    t.text     "production_countries"
    t.text     "spoken_languages"
    t.date     "release_date"
    t.float    "imdb_score"
  end

  create_table "providers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shows", force: :cascade do |t|
    t.datetime "starts_at"
    t.integer  "movie_id"
    t.integer  "theater_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "shows", ["movie_id"], name: "index_shows_on_movie_id", using: :btree
  add_index "shows", ["theater_id"], name: "index_shows_on_theater_id", using: :btree

  create_table "streamings", force: :cascade do |t|
    t.string   "consumption"
    t.string   "link"
    t.integer  "price"
    t.integer  "movie_id"
    t.integer  "provider_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "streamings", ["movie_id"], name: "index_streamings_on_movie_id", using: :btree
  add_index "streamings", ["provider_id"], name: "index_streamings_on_provider_id", using: :btree

  create_table "theaters", force: :cascade do |t|
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "address"
    t.string   "provider"
    t.string   "uid"
    t.string   "picture"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "token"
    t.datetime "token_expiry"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "interests", "movies"
  add_foreign_key "interests", "users"
  add_foreign_key "shows", "movies"
  add_foreign_key "shows", "theaters"
  add_foreign_key "streamings", "movies"
  add_foreign_key "streamings", "providers"
end
