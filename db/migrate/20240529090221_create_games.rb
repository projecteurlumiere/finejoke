class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :max_players
      t.integer :max_rounds
      t.integer :max_round_time
      t.integer :max_points
      t.string  :name, null: false
      t.boolean :started, default: false
      t.boolean :ended, default: false

      t.timestamps
    end
  end
end
