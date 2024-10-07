class CreateBans < ActiveRecord::Migration[7.1]
  def change
    create_table :bans do |t|
      t.references :game, type: :string, foreign_key: true
      t.references :user, foreign_key: true
      t.string :ip
      t.integer :n_times_kicked, default: 1
      t.boolean :enforced, default: false

      t.timestamps
    end

    add_index :bans, :ip
  end
end
