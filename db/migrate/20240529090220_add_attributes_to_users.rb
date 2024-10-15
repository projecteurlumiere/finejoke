# frozen_string_literal: true

class AddAttributesToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :username, null: false
      t.string :game_id

      # ws related (unused)
      t.boolean :connected, default: false
      t.boolean :subscribed_to_game, default: false

      # game related
      t.boolean :host, default: false
      t.boolean :hot_join, default: false
      t.boolean :lead, default: false
      t.boolean :was_lead, default: false
      t.boolean :finished_turn, default: false
      t.boolean :wants_to_skip_results, default: false
      t.boolean :voted, default: false
      t.integer :current_score, default: false

      # statistics:
      t.integer :total_score, default: 0
      t.integer :total_setups, default: 0
      t.integer :total_punchlines, default: 0
      t.integer :total_suggestions, default: 0
      t.integer :total_games, default: 0
      t.integer :total_wins, default: 0

      # profile related:
      t.boolean :show_jokes_allowed, default: true
      t.boolean :show_awards_allowed, default: true
    end

    add_index :users, :username, unique: true
  end
end
