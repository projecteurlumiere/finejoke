# frozen_string_literal: true

class AddAttributesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :game_id, :integer
    add_column :users, :online, :boolean
    add_column :users, :host, :boolean
    add_column :users, :lead, :boolean # his/her turn
    add_column :users, :current_points, :integer
  end
end
