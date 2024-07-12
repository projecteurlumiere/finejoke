class CreatePresents < ActiveRecord::Migration[7.1]
  def change
    # If you want to add an index for faster querying through this join:
    create_table :presents do |t|
      t.string :name
      t.string :description
      # or something
      t.string :icon
      
      t.timestamps
    end
  end
end
