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

ActiveRecord::Schema.define(version: 20180112235400) do

  create_table "arts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "unique_token"
    t.string   "element_id"
    t.integer  "art_id"
    t.float    "x_pos"
    t.float    "y_pos"
    t.string   "shape"
    t.string   "color"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "bot_tasks", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "unique_token"
    t.string   "name"
    t.text     "body"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "bot_id"
    t.string   "page"
  end

  create_table "bots", force: :cascade do |t|
    t.string   "unique_token"
    t.string   "name"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "image"
    t.integer  "user_id"
    t.integer  "bot_id"
    t.string   "page"
    t.string   "parent_tokens"
  end

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "product_token_list"
    t.string   "unique_token"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "comment_id"
    t.text     "body"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "anon_token"
    t.string   "image"
    t.integer  "bot_id"
    t.integer  "proposal_id"
    t.integer  "vote_id"
    t.integer  "like_id"
    t.integer  "note_id"
    t.boolean  "forrest_only"
  end

  create_table "connections", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "other_user_id"
    t.integer  "group_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.boolean  "invite"
    t.boolean  "request"
    t.string   "anon_token"
    t.string   "unique_token"
    t.boolean  "redeemed"
    t.boolean  "grant_dev_access"
    t.boolean  "message_folder"
    t.integer  "connection_id"
    t.integer  "total_messages_seen"
    t.boolean  "grant_mod_access"
    t.string   "invite_password"
    t.boolean  "grant_gk_access"
    t.boolean  "portal"
    t.integer  "total_items_seen"
    t.boolean  "forrest_only"
    t.datetime "last_typing_at"
    t.boolean  "mod"
    t.boolean  "admin"
    t.string   "title"
    t.integer  "game_id"
  end

  create_table "crono_jobs", force: :cascade do |t|
    t.string   "job_id",                               null: false
    t.text     "log",               limit: 1073741823
    t.datetime "last_performed_at"
    t.boolean  "healthy"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "game_pieces", force: :cascade do |t|
    t.string   "unique_token"
    t.integer  "user_id"
    t.integer  "treasure_id"
    t.integer  "secret_id"
    t.string   "name"
    t.text     "body"
    t.string   "image"
    t.string   "game_type"
    t.string   "piece_type"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "game_piece_id"
    t.integer  "game_id"
    t.string   "game_class"
    t.integer  "level"
    t.string   "ability"
    t.boolean  "active"
    t.integer  "level_requirement"
    t.string   "item_type"
    t.integer  "cost"
    t.datetime "expires_at"
    t.boolean  "game_class_preset"
    t.float    "health"
    t.float    "stamina"
    t.float    "mana"
  end

  create_table "games", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "folder_id"
    t.string   "title"
    t.string   "name"
    t.string   "body"
    t.string   "description"
    t.string   "ability"
    t.string   "stats"
    t.boolean  "active"
    t.string   "item_type"
    t.datetime "expires_at"
    t.string   "unique_token"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "game_type"
    t.integer  "current_turn_of_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "anon_token"
    t.string   "image"
    t.integer  "user_id"
    t.string   "unique_token"
    t.boolean  "open"
    t.string   "passphrase"
    t.boolean  "pass_protected"
    t.integer  "ratification_threshold"
    t.integer  "view_limit"
    t.datetime "expires_at"
    t.boolean  "hidden"
    t.string   "social_structure"
    t.integer  "total_items_seen"
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "anon_token"
    t.integer  "post_id"
    t.integer  "comment_id"
    t.string   "unique_token"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "proposal_id"
    t.integer  "vote_id"
    t.integer  "like_id"
    t.integer  "liked_user_id"
    t.boolean  "love"
    t.boolean  "whoa"
    t.boolean  "zen"
    t.boolean  "hype"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "receiver_id"
    t.integer  "group_id"
    t.text     "body"
    t.string   "image"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "anon_token"
    t.string   "receiver_token"
    t.integer  "connection_id"
    t.string   "sender_token"
    t.string   "salt"
    t.string   "unique_token"
  end

  create_table "notes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "sender_id"
    t.string   "message"
    t.string   "action"
    t.boolean  "seen"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "anon_token"
    t.string   "sender_token"
    t.integer  "item_id"
    t.string   "item_token"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "product_token_list"
    t.integer  "total_cents"
    t.string   "address"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "unique_token"
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "post_id"
    t.string   "image"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "wiki_id"
    t.integer  "product_id"
    t.string   "classifier_name"
  end

  create_table "portals", force: :cascade do |t|
    t.string   "unique_token"
    t.datetime "expires_at"
    t.integer  "remaining_uses"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "cluster"
    t.integer  "cluster_id"
    t.integer  "creator_id"
    t.integer  "user_id"
    t.boolean  "mod"
    t.boolean  "dev"
    t.boolean  "admin"
    t.boolean  "goddess"
    t.boolean  "god"
    t.boolean  "expired"
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "body"
    t.string   "image"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "anon_token"
    t.integer  "group_id"
    t.integer  "original_id"
    t.boolean  "hidden"
    t.boolean  "photoset"
    t.string   "unique_token"
    t.boolean  "forrest_only"
    t.boolean  "un_invited"
    t.string   "video"
    t.boolean  "sound"
    t.string   "audio"
    t.string   "audio_name"
  end

  create_table "products", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "wish_list_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "body"
    t.string   "unique_token"
    t.         "price"
    t.integer  "price_cents",    default: 0,     null: false
    t.string   "price_currency", default: "USD", null: false
  end

  create_table "proposals", force: :cascade do |t|
    t.string   "unique_token"
    t.string   "anon_token"
    t.string   "group_token"
    t.integer  "group_id"
    t.integer  "proposal_id"
    t.string   "title"
    t.text     "body"
    t.string   "image"
    t.string   "action"
    t.string   "revised_action"
    t.boolean  "ratified"
    t.boolean  "requires_revision"
    t.boolean  "revised"
    t.integer  "version"
    t.integer  "ratification_point"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "misc_data"
    t.integer  "user_id"
    t.string   "voting_type"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.string   "body"
    t.integer  "stars"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "secrets", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "secret_id"
    t.string   "unique_token"
    t.string   "name"
    t.text     "body"
    t.string   "image"
    t.integer  "xp"
    t.string   "node_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "treasure_id"
  end

  create_table "settings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "name"
    t.boolean  "on"
    t.string   "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["key"], name: "idx_key"
  end

  create_table "sounds", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.string   "name"
    t.string   "audio"
    t.string   "unique_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "post_id"
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "group_id"
    t.integer  "comment_id"
    t.string   "tag"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "anon_token"
    t.integer  "index"
    t.integer  "proposal_id"
    t.integer  "vote_id"
    t.integer  "message_id"
  end

  create_table "template_items", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.string   "image"
    t.boolean  "photoset"
    t.string   "video"
    t.string   "tag"
    t.string   "unique_token"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "tests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "treasures", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "treasure_id"
    t.string   "unique_token"
    t.integer  "xp"
    t.string   "power"
    t.float    "chance"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "image"
    t.text     "body"
    t.string   "treasure_type"
    t.string   "answer"
    t.string   "options"
    t.string   "name"
    t.boolean  "expired"
    t.datetime "expires_at"
    t.integer  "secret_id"
    t.string   "anon_token"
    t.integer  "giver_id"
    t.string   "secret_message"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "passphrase"
    t.binary   "salt"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "auth_token"
    t.string   "image"
    t.text     "body"
    t.string   "email"
    t.string   "password"
    t.string   "password_salt"
    t.string   "unique_token"
    t.boolean  "dev"
    t.boolean  "mod"
    t.integer  "xp"
    t.boolean  "gatekeeper"
    t.datetime "last_active_at"
    t.boolean  "god"
    t.boolean  "hidden"
    t.string   "title"
    t.boolean  "forrest_only"
    t.string   "foc_unique_token"
    t.boolean  "guest"
    t.boolean  "goddess"
    t.string   "meme_war_class"
    t.string   "zodiac"
    t.integer  "energy_points"
  end

  create_table "views", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "anon_token"
    t.integer  "group_id"
    t.integer  "post_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "comment_id"
    t.integer  "profile_id"
    t.string   "ip_address"
    t.integer  "proposal_id"
    t.integer  "message_id"
    t.string   "locale"
    t.integer  "vote_id"
    t.integer  "score_count"
    t.boolean  "non_visible"
    t.boolean  "click"
    t.integer  "x_pos"
    t.integer  "y_pos"
    t.integer  "screen_width"
    t.integer  "screen_height"
    t.integer  "avail_screen_width"
    t.integer  "avail_screen_height"
    t.integer  "device_pixel_ratio"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "current_url"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "comment_id"
    t.integer  "vote_id"
    t.string   "unique_token"
    t.string   "anon_token"
    t.text     "body"
    t.string   "flip_state"
    t.boolean  "verified"
    t.integer  "proposal_version"
    t.boolean  "moot"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "user_id"
  end

  create_table "wiki_versions", force: :cascade do |t|
    t.integer  "wiki_id"
    t.text     "title"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wikis", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "title"
    t.text     "body"
    t.integer  "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "photoset"
  end

  create_table "wish_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "product_token_list"
    t.string   "unique_token"
  end

end
