class CreateHostsAndPrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :virtual_hosts do |t|
      t.references :game

      t.timestamps
    end

    create_table :prompts do |t|
      t.string :role, null: false
      t.string :content, null: false
      t.references :virtual_host, null: false

      t.timestamps
    end
  end
end
