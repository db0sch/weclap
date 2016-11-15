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

ActiveRecord::Schema.define(version: 20161011160821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

  create_table "friendships", force: :cascade do |t|
    t.integer  "buddy_id"
    t.integer  "friend_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buddy_id"], name: "index_friendships_on_buddy_id", using: :btree
    t.index ["friend_id"], name: "index_friendships_on_friend_id", using: :btree
  end

  create_table "interests", force: :cascade do |t|
    t.datetime "watched_on"
    t.integer  "user_id"
    t.integer  "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "rating"
    t.index ["movie_id"], name: "index_interests_on_movie_id", using: :btree
    t.index ["user_id"], name: "index_interests_on_user_id", using: :btree
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "title"
    t.integer  "person_id"
    t.integer  "movie_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_jobs_on_movie_id", using: :btree
    t.index ["person_id"], name: "index_jobs_on_person_id", using: :btree
  end

  create_table "movies", force: :cascade do |t|
    t.string   "title"
    t.string   "original_title"
    t.integer  "runtime"
    t.string   "tagline"
    t.json     "credits"
    t.string   "poster_url"
    t.string   "trailer_url"
    t.string   "website_url"
    t.string   "imdb_id"
    t.string   "cnc_url"
    t.integer  "tmdb_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.json     "genres"
    t.text     "overview"
    t.float    "popularity"
    t.string   "original_language"
    t.text     "spoken_languages"
    t.date     "release_date"
    t.float    "imdb_score"
    t.json     "collection"
    t.boolean  "setup",             default: false
    t.boolean  "adult",             default: false
    t.string   "fr_title"
    t.string   "fr_tagline"
    t.string   "fr_overview"
    t.date     "fr_release_date"
    t.tsvector "tsv"
    t.tsvector "tsv_optional"
    t.index ["fr_title", "original_title", "title"], name: "index_movies_on_fr_title_and_original_title_and_title", using: :btree
    t.index ["tsv"], name: "index_movies_on_tsv", using: :gin
    t.index ["tsv_optional"], name: "index_movies_on_tsv_optional", using: :gin
  end

  create_table "people", force: :cascade do |t|
    t.string   "name"
    t.string   "tmdb_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["movie_id"], name: "index_shows_on_movie_id", using: :btree
    t.index ["theater_id"], name: "index_shows_on_theater_id", using: :btree
  end

  create_table "streamings", force: :cascade do |t|
    t.string   "consumption"
    t.string   "link"
    t.integer  "price"
    t.integer  "movie_id"
    t.integer  "provider_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["movie_id"], name: "index_streamings_on_movie_id", using: :btree
    t.index ["provider_id"], name: "index_streamings_on_provider_id", using: :btree
  end

  create_table "theaters", force: :cascade do |t|
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "address"
    t.string   "provider"
    t.string   "uid"
    t.string   "picture"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "token"
    t.datetime "token_expiry"
    t.string   "access_token"
    t.string   "full_name_friendlist"
    t.string   "fullname"
    t.string   "zip_code",               default: "75001"
    t.string   "city",                   default: "Paris"
    t.boolean  "admin",                  default: false,   null: false
    t.json     "friendslist"
    t.string   "messenger_id"
    t.string   "secondary_email"
    t.boolean  "newsletter",             default: false
    t.integer  "wl_list_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "interests", "movies"
  add_foreign_key "interests", "users"
  add_foreign_key "jobs", "movies"
  add_foreign_key "jobs", "people"
  add_foreign_key "shows", "movies"
  add_foreign_key "shows", "theaters"
  add_foreign_key "streamings", "movies"
  add_foreign_key "streamings", "providers"
end
