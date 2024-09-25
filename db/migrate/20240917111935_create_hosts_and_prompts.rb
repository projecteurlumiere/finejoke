class CreateHostsAndPrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :virtual_hosts do |t|
      t.references :game, type: :string
      t.boolean :voiced, null: false, default: false

      t.timestamps
    end

    create_table :prompts do |t|
      t.string :role, null: false
      t.string :content, null: false
      t.boolean :summary, null: false, default: false
      t.references :virtual_host, null: false

      t.timestamps
    end
  end
end
