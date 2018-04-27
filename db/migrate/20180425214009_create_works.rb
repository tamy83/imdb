class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :title, null: false
      t.string :url
      t.decimal :rating
      t.integer :category, null: false, default: 0
      t.timestamps null: false
    end
    add_index :works, :url, unique: true
  end
end
