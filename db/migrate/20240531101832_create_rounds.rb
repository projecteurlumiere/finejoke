class CreateRounds < ActiveRecord::Migration[7.1]
  def change
    create_table :rounds do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :last, default: false
      t.integer :stage, default: 0
      t.string :setup
      t.timestamps
    end
  end
end
