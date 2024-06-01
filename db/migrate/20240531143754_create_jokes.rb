class CreateJokes < ActiveRecord::Migration[7.1]
  def change
    create_table :jokes do |t|
      t.string :punchline
      t.string :text
      t.references :round, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
