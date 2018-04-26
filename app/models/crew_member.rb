class CrewMember < ActiveRecord::Base

  belongs_to :person
  belongs_to :work
  has_many :crew_members_roles
  has_many :roles, through: :crew_members_roles

end
