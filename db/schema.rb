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

ActiveRecord::Schema.define(:version => 20130826113326) do

  create_table "annotations", :force => true do |t|
    t.integer  "version_id"
    t.integer  "member_id"
    t.string   "coordinates"
    t.string   "camera"
    t.string   "text"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "annotations", ["created_at"], :name => "index_annotations_on_created_at"
  add_index "annotations", ["member_id"], :name => "index_annotations_on_member_id"
  add_index "annotations", ["version_id"], :name => "index_annotations_on_version_id"

  create_table "discussions", :force => true do |t|
    t.integer  "annotation_id"
    t.integer  "member_id"
    t.string   "text"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "discussions", ["annotation_id"], :name => "index_discussions_on_annotation_id"
  add_index "discussions", ["created_at"], :name => "index_discussions_on_created_at"
  add_index "discussions", ["member_id"], :name => "index_discussions_on_member_id"

  create_table "group_members", :force => true do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "group_members", ["group_id", "member_id"], :name => "index_group_members_on_group_id_and_member_id", :unique => true
  add_index "group_members", ["group_id"], :name => "index_group_members_on_group_id"
  add_index "group_members", ["member_id"], :name => "index_group_members_on_member_id"

  create_table "group_projects", :force => true do |t|
    t.integer  "group_id"
    t.integer  "project_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "group_projects", ["group_id", "project_id"], :name => "index_group_projects_on_group_id_and_project_id", :unique => true
  add_index "group_projects", ["group_id"], :name => "index_group_projects_on_group_id"
  add_index "group_projects", ["project_id"], :name => "index_group_projects_on_project_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "group_type_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "groups", ["group_type_id"], :name => "index_groups_on_group_type_id"

  create_table "members", :force => true do |t|
    t.integer  "dropbox_uid"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "members", ["dropbox_uid"], :name => "index_members_on_dropbox_uid"

  create_table "model_files", :force => true do |t|
    t.integer  "member_id"
    t.string   "path"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "model_files", ["member_id", "path"], :name => "index_model_files_on_member_id_and_path", :unique => true

  create_table "notifications", :force => true do |t|
    t.integer  "member_id"
    t.integer  "count",      :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "notifications", ["member_id"], :name => "index_notifications_on_member_id"

  create_table "project_model_files", :force => true do |t|
    t.integer  "project_id"
    t.integer  "model_file_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "project_model_files", ["created_at"], :name => "index_project_model_files_on_created_at"
  add_index "project_model_files", ["model_file_id"], :name => "index_project_model_files_on_model_file_id"
  add_index "project_model_files", ["project_id", "model_file_id"], :name => "index_project_model_files_on_project_id_and_model_file_id", :unique => true
  add_index "project_model_files", ["project_id"], :name => "index_project_model_files_on_project_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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
    t.string   "details"
    t.datetime "revision_date"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["model_file_id", "revision_number"], :name => "index_versions_on_model_file_id_and_revision_number", :unique => true
  add_index "versions", ["revision_date"], :name => "index_versions_on_revision_date"

end
