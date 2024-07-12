class CreateJokes < ActiveRecord::Migration[7.1]
  def change
    create_table :jokes do |t|
      t.string :setup
      t.string :punchline
      t.string :text
      t.integer :votes, default: 0
      t.references :round, foreign_key: true
      t.references :punchline_author, foreign_key: { to_table: :users }
      t.references :setup_author, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
