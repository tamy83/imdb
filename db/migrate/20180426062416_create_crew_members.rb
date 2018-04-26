class CreateCrewMembers < ActiveRecord::Migration
  def change
    create_table :crew_members do |t|
      t.references :person
      t.references :work
      t.timestamps null: false
    end

    add_index :crew_members, [:person_id, :work_id], unique: true

    create_join_table :crew_members, :roles do |t|
      t.references :crew_member
      t.references :role
    end    
  end
end
