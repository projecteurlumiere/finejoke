class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :max_players, null: false, default: 10
      t.integer :max_round_time, null: false, default: 90 # in seconds
      t.integer :max_rounds
      t.integer :max_points
      t.string  :name, null: false
      t.boolean :viewable, null: false, default: true
      t.boolean :viewers_vote, null: false, default: false
      t.integer :winner_id
      t.integer :status, null: false, default: 0
      t.integer :afk_rounds, null: false, default: 0
      t.integer :n_rounds, null: false, default: 0
      t.integer :n_players, null: false, default: 0
      t.integer :n_viewers, null: false, default: 0
      t.references :host, foreign_key: { to_table: :users }
      t.string :host_username, null: false

      t.timestamps
    end
  end
end
