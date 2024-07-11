class CreateJokes < ActiveRecord::Migration[7.1]
  def change
    create_table :jokes do |t|
      t.string :setup
      t.string :punchline
      t.string :text
      t.integer :votes, default: 0
      t.references :round, foreign_key: true
      t.references :punchline_author
      t.references :setup_author

      t.timestamps
    end

     add_foreign_key :jokes, :users, column: :punchline_author_id, primary_key: :id
  end
end
