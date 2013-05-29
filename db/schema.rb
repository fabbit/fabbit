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

ActiveRecord::Schema.define(:version => 20130425232357) do

  create_table "annotations", :force => true do |t|
    t.integer  "version_id"
    t.string   "coordinates"
    t.string   "camera"
    t.string   "text"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "user_id"
  end

  add_index "annotations", ["version_id"], :name => "index_annotations_on_revision_id"

  create_table "discussions", :force => true do |t|
    t.integer  "annotation_id"
    t.string   "member_id"
    t.string   "text"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "members", :force => true do |t|
    t.integer  "dropbox_uid"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "name"
  end

  add_index "members", ["dropbox_uid"], :name => "index_users_on_dropbox_uid"

  create_table "model_files", :force => true do |t|
    t.string   "user"
    t.string   "path"
    t.string   "cached_revision"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "member_id"
  end

  add_index "model_files", ["user", "path"], :name => "index_model_files_on_user_and_path", :unique => true

  create_table "project_members", :force => true do |t|
    t.integer  "project_id"
    t.integer  "member_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "project_members", ["member_id"], :name => "index_project_members_on_member_id"
  add_index "project_members", ["project_id"], :name => "index_project_members_on_project_id"

  create_table "project_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.integer  "project_type_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "projects", ["project_type_id"], :name => "index_projects_on_project_type_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "versions", :force => true do |t|
    t.integer  "model_file_id"
    t.string   "revision_number"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "details"
    t.datetime "revision_date"
  end

  add_index "versions", ["model_file_id", "revision_number"], :name => "index_revisions_on_model_file_id_and_revision_number"
  add_index "versions", ["revision_date"], :name => "index_versions_on_revision_date"

end
