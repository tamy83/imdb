class CrewMember < ActiveRecord::Base

  belongs_to :person
  belongs_to :work
  has_and_belongs_to_many :roles

end
