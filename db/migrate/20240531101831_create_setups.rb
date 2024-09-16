class CreateSetups < ActiveRecord::Migration[7.1]
  def change
    create_table :setups do |t|
      t.string :text, null: false
      t.string :text_short

      t.references :user
    end
  end
end
