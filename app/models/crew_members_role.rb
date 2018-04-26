class CrewMembersRole < ActiveRecord::Base

  belongs_to :crew_member
  belongs_to :role

end
