class CreateWorks < ActiveRecord::Migration
  def change
    create_table :works do |t|
      t.string :title
      t.string :url, null: false
      t.decimal :rating, precision: 4, scale: 2
      t.integer :category, null: false, default: 0
      t.timestamps null: false
    end
    add_index :works, :url, unique: true
  end
end
