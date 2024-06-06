# frozen_string_literal: true

class AddAttributesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :username, :string
    add_column :users, :game_id, :integer
    add_column :users, :online, :boolean
    add_column :users, :host, :boolean, default: false
    add_column :users, :lead, :boolean, default: false # his/her turn
    add_column :users, :was_lead, :boolean, default: false # his/her turn recently
    add_column :users, :finished_turn, :boolean, default: false
    add_column :users, :voted, :boolean, default: false
    add_column :users, :current_score, :integer, default: 0
    add_column :users, :total_score, :integer, default: 0
  end
end
