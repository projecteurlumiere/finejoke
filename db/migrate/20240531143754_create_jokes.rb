class CreateJokes < ActiveRecord::Migration[7.1]
  def change
    create_table :jokes do |t|
      t.references :setup_model, null: false, foreign_key: { to_table: :setups }
      t.string :punchline, null: false
      t.integer :n_votes, null: false, default: 0
      t.references :round, foreign_key: true
      t.references :user

      t.timestamps
    end
  end
end
