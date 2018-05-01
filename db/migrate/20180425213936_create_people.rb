class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.string :photo_url
      t.string :profile_url, null: false
      t.string :work_rankings
      t.date  :birthdate
      t.timestamps null: false
    end
    add_index :people, :profile_url, unique: true
  end
end
