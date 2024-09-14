class AddAiSuggestions < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :ai_allowed, :boolean, default: true

    add_column :users, :credits, :integer, default: 0
    add_column :users, :unlimited_credits_deadline, :datetime, default: Time.now + 1000.year

    add_column :users, :suggestions, :integer, array: true, default: []
    add_column :rounds, :suggestions, :integer, array: true, default: []

    add_column :jokes, :setup_suggested, :boolean, null: false, default: false
    add_column :jokes, :punchline_suggested, :boolean, null: false, default: false

    create_join_table :jokes, :suggestions do |t|
      t.index :joke_id
      t.index :suggestion_id
    end

    create_table :suggestions do |t|
      t.string :output, null: false
      t.integer :target, null: false

      t.timestamps
    end
  end
end
