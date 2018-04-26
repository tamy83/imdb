class CreateCrewMembers < ActiveRecord::Migration
  def change
    create_table :crew_members do |t|
      t.references :person
      t.references :work
      t.timestamps null: false
    end

    add_index :crew_members, [:person_id, :work_id], unique: true

    create_join_table :crew_members, :roles do |t|
      t.references :crew_member, index: true, null: false, foreign_key: {on_delete: :cascade}
      t.references :role, index: true, null: false, foreign_key: {on_delete: :cascade}
    end
  end
end
