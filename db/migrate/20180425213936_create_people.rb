class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.string :photo_url
      t.string :profile_url
      t.date  :birthdate
      t.timestamps null: false
    end
  end
end
