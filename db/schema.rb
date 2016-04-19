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

ActiveRecord::Schema.define(version: 20160409173658) do

  create_table "moves", force: :cascade do |t|
    t.string  "name"
    t.string  "description"
    t.integer "type_1"
    t.integer "category"
    t.integer "power"
    t.integer "accuracy"
    t.integer "power_points"
    t.integer "status_effect"
    t.integer "status_effect_chance"
    t.integer "stat_type"
    t.integer "stage_change"
    t.integer "stat_change_chance"
  end

  create_table "pokemon_moves", force: :cascade do |t|
    t.integer "pokemon_id"
    t.integer "move_id"
  end

  add_index "pokemon_moves", ["move_id"], name: "index_pokemon_moves_on_move_id"
  add_index "pokemon_moves", ["pokemon_id"], name: "index_pokemon_moves_on_pokemon_id"

  create_table "pokemons", force: :cascade do |t|
    t.string  "name"
    t.integer "type_1"
    t.integer "type_2"
    t.integer "hp"
    t.integer "attack"
    t.integer "defense"
    t.integer "special_attack"
    t.integer "special_defense"
    t.integer "speed"
  end

end
