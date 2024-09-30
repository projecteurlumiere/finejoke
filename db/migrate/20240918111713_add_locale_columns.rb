class AddLocaleColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :locale, :integer, null: false, default: 0
    add_column :games, :locale, :integer, null: false, default: 0
    add_column :setups, :locale, :integer, null: false, default: 0
    add_column :jokes, :locale, :integer, null: false, default: 0
    add_column :awards, :locale, :integer, null: false, default: 0
    add_column :suggestions, :locale, :integer, null: false, default: 0
    add_column :virtual_hosts, :locale, :integer, null: false, default: 0
    add_column :prompts, :locale, :integer, null: false, default: 0
  end
end
