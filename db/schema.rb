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

ActiveRecord::Schema.define(version: 20170607071552) do

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

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "comment_id"
    t.text     "body"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "anon_token"
    t.string   "image"
    t.integer  "bot_id"
    t.integer  "proposal_id"
    t.integer  "vote_id"
    t.integer  "like_id"
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
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "game_piece_id"
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

  create_table "pictures", force: :cascade do |t|
    t.integer  "post_id"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "portals", force: :cascade do |t|
    t.string   "unique_token"
    t.datetime "expires_at"
    t.integer  "remaining_uses"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
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
    t.string   "voting_typpe"
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

  create_table "treasures", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "treasure_id"
    t.string   "unique_token"
    t.integer  "xp"
    t.string   "power"
    t.float    "chance"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
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
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "passphrase"
    t.binary   "salt"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
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
  end

  create_table "views", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "anon_token"
    t.integer  "group_id"
    t.integer  "post_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "comment_id"
    t.integer  "profile_id"
    t.string   "ip_address"
    t.integer  "proposal_id"
    t.integer  "message_id"
    t.string   "locale"
    t.integer  "vote_id"
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

end
