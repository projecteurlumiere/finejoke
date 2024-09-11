class AddAiSuggestions < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :credits, :integer, default: 999
    add_column :games, :ai_allowed, :boolean, default: true
  end
end
