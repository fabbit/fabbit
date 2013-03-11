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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130311212501) do

  create_table "annotations", :force => true do |t|
    t.integer  "revision_id"
    t.string   "coordinates"
    t.string   "camera"
    t.string   "text"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "annotations", ["revision_id"], :name => "index_annotations_on_revision_id"

  create_table "model_files", :force => true do |t|
    t.string   "user"
    t.string   "path"
    t.integer  "cached_revision"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "model_files", ["path", "cached_revision"], :name => "index_model_files_on_path_and_cached_revision"
  add_index "model_files", ["user"], :name => "index_model_files_on_user"

  create_table "revisions", :force => true do |t|
    t.integer  "model_file_id"
    t.integer  "revision_number"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "revisions", ["model_file_id", "revision_number"], :name => "index_revisions_on_model_file_id_and_revision_number"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "password_digest"
  end

end
