class AddAiSuggestions < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :suggestable, :boolean, null: false, default: true

    change_table :users, bulk: true do |t|
      t.integer :suggestion_quota, default: 5, null: false

      t.integer :suggestions, array: true, null: false, default: []
    end

    add_column :rounds, :suggestions, :integer, array: true, null: false, default: []

    change_table :jokes, bulk: true do |t|
      t.boolean :setup_suggested, null: false, default: false
      t.boolean :punchline_suggested, null: false, default: false 
    end

    create_table :suggestions do |t|
      t.string :output, null: false
      t.integer :target, null: false
      t.string :context # usually setup
      t.string :user_input # usually whatever user writes in the input field

      t.timestamps
    end

    create_join_table :jokes, :suggestions do |t|
      t.index :joke_id
      t.index :suggestion_id
    end
  end
end
