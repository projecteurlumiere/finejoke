class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :user
      t.references :joke, null: false
      t.references :round
      t.integer :weight, null: false, default: 1

      t.timestamps
    end
  end
end
