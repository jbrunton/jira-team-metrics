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

ActiveRecord::Schema.define(version: 2018_06_02_115504) do

  create_table "jira_team_metrics_boards", force: :cascade do |t|
    t.string "jira_id"
    t.string "name"
    t.string "query"
    t.text "config_string"
    t.datetime "synced_from"
    t.datetime "last_synced"
    t.integer "domain_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain_id"], name: "index_jira_team_metrics_boards_on_domain_id"
  end

  create_table "jira_team_metrics_domains", force: :cascade do |t|
    t.string "statuses"
    t.string "fields"
    t.text "config_string"
    t.datetime "last_synced"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "syncing"
  end

  create_table "jira_team_metrics_filters", force: :cascade do |t|
    t.string "name"
    t.string "issue_keys"
    t.integer "filter_type"
    t.integer "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_jira_team_metrics_filters_on_board_id"
  end

  create_table "jira_team_metrics_issues", force: :cascade do |t|
    t.string "key"
    t.string "issue_type"
    t.string "summary"
    t.datetime "issue_created"
    t.string "status"
    t.string "labels"
    t.string "transitions"
    t.string "fields"
    t.string "links"
    t.integer "board_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_jira_team_metrics_issues_on_board_id"
  end

  create_table "jira_team_metrics_report_fragments", force: :cascade do |t|
    t.integer "board_id"
    t.string "report_key"
    t.string "fragment_key"
    t.text "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_jira_team_metrics_report_fragments_on_board_id"
  end

end
